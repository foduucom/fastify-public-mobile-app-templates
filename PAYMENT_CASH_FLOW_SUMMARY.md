# Cash Payment Flow: Investigation and Changes

**Date:** 2026-11-10  
**Scope:** Flutter checkout cash/Cash on Delivery flow, from payment-method loading through the order-success screen.

## Overview

The checkout flow was updated so a customer can choose the store's `cash` payment method, place an order using the existing cash-capable website route, and land directly on the app's existing order-success page. The work also addressed the request's payment-method shimmer, a malformed cart payload, a CSRF rejection, and a controller type collision on the success screen.

No backend files were changed. Backend inspection was read only.

## 1. Payment-method loading

### Problem

The checkout log showed `/api/payment-methods` returning HTTP 200 while the UI kept displaying the payment-method shimmer. The view used an empty `paymentOptions` list as its loading condition, so an empty or differently wrapped response looked like an unfinished request forever.

### Changes

- Added `isLoadingPaymentMethods` to `CheckOutController` and clear it in a `finally` block after the request completes.
- Recognized a `payment_methods` or `paymentMethods` wrapper as well as direct map/list responses.
- Allowed the API's `cash` configuration entry to enable the existing COD payment tile. The app may use `cod` as its internal tile key, while sending `cash` to the parent website's checkout route.
- Changed the checkout view to show the shimmer only while loading. After a completed response with no usable methods, it shows an empty-state message instead.

Relevant files:

- `lib/app/modules/checkout/controllers/checkout_controllers.dart`
- `lib/app/modules/checkout/views/checkout_views.dart`

## 2. Order payload diagnosis and cash route

### Original error

The first `/api/order/create` request returned HTTP 500. The response shown in the API screenshot and the backend log identified a Mongoose cast error for `Product_Variant`: the backend received `"[object Object]"` where it expected a variant ObjectId.

The app had been sending fully populated cart objects in `items`. Their `product_id` and `variant_id` fields could themselves be maps. In the mobile API handler, calling `.toString()` on a populated variant map yielded `"[object Object]"` before the `Product_Variant` query.

Backend source inspection also showed a payment-contract difference:

- `/api/order/create` accepts `cod` for COD orders, not the literal `cash` value.
- The existing public website route `/checkout/place-order` accepts `cash`, supports the authenticated customer context, and can load the customer's saved cart when `items` is omitted.

### Changes

- Cash orders now use the existing `checkout/place-order` route. Online gateway orders continue using `/api/order/create`.
- Cash order requests keep `primary_method: "cash"` and send the selected address, secondary method, notes, and coupon fields.
- The app omits the populated `items` array. The website route resolves the customer's saved cart server side, avoiding the malformed `variant_id` object and leaving product/variant details and prices to backend records.
- Added an optional `baseUrl` to `BasicProvider` so the same request helper can call a route at the store root as well as an `/api` route.
- Added optional `extraHeaders` support to `BasicProvider.postRequest`.

Relevant files:

- `lib/app/data/basic_provider.dart`
- `lib/app/modules/checkout/controllers/checkout_controllers.dart`

## 3. CSRF support for the website checkout route

### Follow-up error

The website route initially returned HTTP 500 with a backend log entry saying `CSRF rejected [POST /checkout/place-order]: Missing csrf secret`. That route is protected by the website's CSRF middleware; a native app POST does not automatically carry the browser cookie/token pair.

### Changes

- Before a cash order POST, the app GETs the store homepage using the normal access key and customer bearer token.
- It reads the CSRF token from the page's `csrf-token` meta tag and the signed `_csrf` value from `Set-Cookie`.
- It sends both the `_csrf` cookie and `x-csrf-token` header with `/checkout/place-order`.
- If the page does not supply either value, the app throws during checkout initialization and stops before submitting the order; it does not send a knowingly invalid POST.

The backend was only inspected. No CSRF exemptions or backend route changes were made. A read-only request confirmed that the store homepage exposes the CSRF meta tags and `_csrf` cookie.

Relevant files:

- `lib/app/modules/checkout/controllers/checkout_controllers.dart`
- `lib/app/data/basic_provider.dart`

## 4. Cash order placement and success navigation

### Changes

- Added checkout submission state so repeated taps are blocked while order creation or COD prepayment is active.
- Cash selection recognizes either the internal `cod` tile name or a `cash` name from a list response.
- Removed the simulated `CODPayment` success step. A cash order is considered placed only after the order endpoint returns a successful response.
- After the cash order succeeds, the cart is refreshed and the app navigates directly to the existing `Routes.ORDERSUCCESS` page. The intermediate generic success dialog was removed from both COD paths.
- COD orders requiring advance payment still run the selected online gateway first; the order-success page is opened only after that payment path succeeds.
- Existing online payment methods retain their payment-success flow.

The public checkout response uses `order_id` for the database order ID. Navigation now recognizes `order_id` as well as `_id` and `id`, while keeping `order_no` as the human-readable order number.

Relevant files:

- `lib/app/modules/checkout/controllers/checkout_controllers.dart`
- `lib/app/modules/orderResponse/controllers/ordersucess_controller.dart`

## 5. Existing order-success page behavior

- The success controller accepts the route's order map, internal ID, order number, and cash-order flag.
- It uses the passed order data immediately, then fetches the full order by its internal ID when available.
- The cash-order flag remains available even if the detail response replaces the initial map.
- `OrdersucessView` displays the existing order animation and details, with cash-specific copy asking the customer to pay on delivery.
- The screen receives `order_id` from the public checkout response so its order-detail request uses the database ID, not just the order number.

Relevant files:

- `lib/app/modules/orderResponse/controllers/ordersucess_controller.dart`
- `lib/app/modules/orderResponse/views/ordersucess_view.dart`

## 6. Order-summary gesture crash

### Error from the pasted runtime log

After the server returned `201` for `/checkout/place-order` and `200` for `/api/order/{id}`, tapping the order summary raised:

> `OrderSuccessController is not a subtype of OrderSuccessController`

The gesture stack pointed to `lib/components/buttons/bottombutton.dart`. That reusable widget imported `OrderSuccessController` from the old payment module, while the active order page used the controller in `orderResponse`. Although the class names matched, the two library types did not.

### Changes

- Updated `bottombutton.dart` to reference the active `orderResponse` controller type.
- Removed the order-success view's redundant `Get.put(OrderSuccessController())`; the route binding supplies the controller instance.

Relevant files:

- `lib/components/buttons/bottombutton.dart`
- `lib/app/modules/orderResponse/views/ordersucess_view.dart`
- `lib/app/modules/orderResponse/bindings/checkout_binding.dart`

## Runtime evidence and verification status

The attached log captured this sequence before the controller-type fix:

1. `POST /checkout/place-order` returned `201`.
2. Cart refresh returned `200`.
3. `GET /api/order/{order_id}` returned `200` and loaded order details.
4. The order-summary tap then failed because it looked up the duplicate controller type.

The controller import/registration fix was applied after that captured log, so the attachment does not prove that final tap behavior has been re-run successfully.

Changed Dart files were formatted and `git diff --check` passed. Automated tests and a new live checkout run were not performed in this work.

## Files changed for this flow

- `lib/app/data/basic_provider.dart`
- `lib/app/modules/checkout/controllers/checkout_controllers.dart`
- `lib/app/modules/checkout/views/checkout_views.dart`
- `lib/app/modules/orderResponse/controllers/ordersucess_controller.dart`
- `lib/app/modules/orderResponse/views/ordersucess_view.dart`
- `lib/components/buttons/bottombutton.dart`

