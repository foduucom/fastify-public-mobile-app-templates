# Form Builder — API Submission Integration Guide

This guide documents the API endpoints for discovering form fields and submitting forms created via the CMS Form Builder.

---

## 1. Overview & Multi-Tenancy

All API requests are multi-tenant and must resolve to a specific website in the CMS.
Multi-tenancy is resolved automatically via:

- The **`Host`** header (e.g., `store.example.com`), OR
- The standard domain/subdomain URL you are making requests to.

### Base URL

```
https://{{your-website-domain}}/api/forms
```

---

## 2. Endpoints Summary

| Method | Endpoint                  | Description                                              | Auth Required         |
| ------ | ------------------------- | -------------------------------------------------------- | --------------------- |
| `GET`  | `/api/forms/:slug`        | Get form field schema, input names, and validation rules | No                    |
| `POST` | `/api/forms/:slug/submit` | Submit form data                                         | Optional (JWT Bearer) |

---

## 3. Endpoint 1: Get Form Schema

Before rendering or submitting a form, query this endpoint to get the active input field names, types, labels, and validation requirements.

### Request

- **Method**: `GET`
- **Path**: `/api/forms/:slug`
- **Headers**:
  ```http
  Accept: application/json
  Host: your-website-domain.com
  ```

> Non-input layout elements (`submit`, `button`, `captcha`, `reset`, `header`, `paragraph`, `hidden`, `total`) are automatically stripped out.

### Success Response (`200 OK`)

```json
{
  "status": "success",
  "data": [
    {
      "name": "full_name",
      "type": "text",
      "label": "Full Name",
      "required": true,
      "placeholder": "Enter your full name",
      "min": 3,
      "max": 100
    },
    {
      "name": "email",
      "type": "email",
      "label": "Email Address",
      "required": true,
      "placeholder": "name@example.com"
    },
    {
      "name": "phone",
      "type": "tel",
      "label": "Phone Number",
      "required": true,
      "min": 10,
      "max": 15
    },
    {
      "name": "department",
      "type": "radio",
      "label": "Department",
      "required": true,
      "options": [
        { "label": "Sales", "value": "sales" },
        { "label": "Support", "value": "support" }
      ]
    },
    {
      "name": "services",
      "type": "checkbox",
      "label": "Services Required",
      "required": false,
      "options": [
        { "label": "Web Development", "value": "web_dev" },
        { "label": "UI/UX Design", "value": "ui_ux" }
      ]
    },
    {
      "name": "message",
      "type": "textarea",
      "label": "Your Message",
      "required": true,
      "min": 10,
      "max": 1000
    }
  ]
}
```

---

## 4. Endpoint 2: Submit Form Data

Submits values entered by the user. Field names in the request body must match the `name` attributes returned by `GET /api/forms/:slug`.

### Request

- **Method**: `POST`
- **Path**: `/api/forms/:slug/submit`
- **Headers**:
  ```http
  Content-Type: application/json
  Host: your-website-domain.com
  Authorization: Bearer <customer_jwt_token>  [Optional: if logged-in customer]
  ```

### Example JSON Body

```json
{
  "full_name": "John Doe",
  "email": "john.doe@example.com",
  "phone": "+19876543210",
  "department": "sales",
  "services": ["web_dev", "ui_ux"],
  "budget": 5000,
  "website": "https://example.com",
  "message": "Hello, we are interested in migrating our system to your platform."
}
```

---

## 5. Field Types & Validation Specifications

All submissions pass through strict backend validation (`FormSubmissionHelper`):

| Field Type                                                    | JSON Type           | Validation Rules                                                                                                                                                          |
| ------------------------------------------------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`text` / `textarea` / `autocomplete` / `url` / `password`** | `string`            | • Required check.<br>• Default minimum: **3 characters** (unless specified otherwise by `min`).<br>• Respects `min` and `max` constraints if configured.                  |
| **`email`**                                                   | `string`            | • Required check.<br>• Regex verification: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`.<br>• Used automatically as recipient if visitor confirmation is turned on. |
| **`tel`**                                                     | `string`            | • Strips non-digit characters (`+`, spaces, `-`, `00`).<br>• Validates minimum & maximum digit counts (`min`, `max`).                                                     |
| **`number`**                                                  | `number` / `string` | • Parsed as float; fails if `NaN`.<br>• Validates digit bounds (`min`, `max`).                                                                                            |
| **`checkbox`**                                                | `array` or `string` | • If required, must contain at least 1 non-empty item.                                                                                                                    |
| **`radio` / `select`**                                        | `string`            | • If required, must have a non-empty selection.                                                                                                                           |
| **`fileupload` / `image`**                                    | Multipart file      | • If required, at least one file must be attached under the field name.                                                                                                   |

---

## 6. Rate Limiting

- **Policy**: Protected by Redis-based IP rate limiter.
- **Limit**: **10 form submissions per IP per website per hour** (`3600 seconds`).
- **Header / Exceeded Response**: Returns **HTTP 429 Too Many Requests** when quota is reached.

---

## 7. What Happens on Successful Submission

When a form is submitted successfully, the backend automatically triggers:

1. **Database Entry**: Creates a `FormSubmission` record storing all values, client IP, metadata, and optional `customer_id`.
2. **Real-Time Notification**: Emits `NEW_FORM_SUBMIT` Socket.IO event to the store owner's dashboard room.
3. **In-App Notification**: Creates an internal notification alert for the website owner.
4. **Owner Multi-Channel Alerts**: Dispatches alerts via configured owner channels:
   - WhatsApp message summary
   - Telegram message
   - SMS
   - Owner notification email
5. **Additional Email Recipients**: If the form defines custom recipient emails in `form.email`, each receives a notification with full submission details.
6. **Marketing Automations**: Fires `MarketingExecutionService.trigger("Form Submission", data)` to run connected workflows or CRM tags.
7. **Visitor Auto-Responder**: If `send_email_to_visitor` is enabled on the form, a confirmation email is dispatched to the user's submitted email address.
8. **Private Storage**: Any uploaded files are moved to protected private storage:
   `UPLOAD_DIR/users/{owner_id}/{website_id}_private/{YYYY}/{MM}/{DD}/`

---

## 8. HTTP Responses & Error Codes

### 200 OK — Submission Successful

```json
{
  "status": "success",
  "message": "Thank you for contacting us. We will get back to you soon."
}
```

### 422 Unprocessable Entity — Validation Failure

Returned when required fields are missing or fail format/length criteria.

```json
{
  "status": "error",
  "message": "Email address is required.",
  "errors": {
    "email": "Email address is required.",
    "phone": "Phone Number must be at least 10 digits.",
    "message": "Your Message must be at least 10 characters."
  }
}
```

### 429 Too Many Requests — Rate Limited

Returned when the submitting IP exceeds 10 submissions within a 1-hour window.

```json
{
  "status": "error",
  "message": "You have submitted this form too many times. Please try again later."
}
```

### 404 Not Found — Invalid Form Slug or Website

```json
{
  "status": "error",
  "message": "Form not found."
}
```

---

## 9. cURL Examples

### 1. Fetch Form Schema

```bash
curl --location 'https://your-domain.com/api/forms/contact-us' \
--header 'Accept: application/json' \
--header 'Host: your-domain.com'
```

### 2. Submit Form Data

```bash
curl --location 'https://your-domain.com/api/forms/contact-us/submit' \
--header 'Content-Type: application/json' \
--header 'Host: your-domain.com' \
--data '{
    "full_name": "Jane Smith",
    "email": "jane.smith@example.com",
    "phone": "+19876543210",
    "department": "sales",
    "message": "We would like to book a product demo."
}'
```
