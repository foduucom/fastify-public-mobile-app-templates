import 'package:flutter/material.dart';
import '/app/modules/Profie/delete_account/controller/delete_account_controller.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import 'package:get/get.dart';

class DeleteAccountView extends GetView<DeleteAccountController> {
  const DeleteAccountView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              'Permanent Account Deletion!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'We feel sorry for you to take this step!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Please note that you are trying to delete your account permanently! The step you are taking right now will delete all your data from the server which will include the following contents:',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                MyBullet(),
                SizedBox(width: 10),
                Text('Account'),
              ],
            ),
            Row(
              children: [
                MyBullet(),
                SizedBox(width: 10),
                Text('Order History'),
              ],
            ),
            Row(
              children: [
                MyBullet(),
                SizedBox(width: 10),
                Text('Subscriptions'),
              ],
            ),
            Row(
              children: [
                MyBullet(),
                SizedBox(width: 10),
                Text('Comment'),
              ],
            ),
            Row(
              children: [
                MyBullet(),
                SizedBox(width: 10),
                Text('Profile Image'),
              ],
            ),
            Row(
              children: [
                MyBullet(),
                SizedBox(width: 10),
                Text('All Account related Data'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'There is no way to recover the account and its content, you will need to further create a new account from scratch.',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 20),
            const Text(
              'If you are facing any technical issue, because of that you are deleting your account. Then please help us to know the problem. We will try to resolve the issue on priority for you. To report the problem please click the below button.',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.toNamed(Routes.CONTACT);
              },
              child: const Text(
                "CONTACT US",
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'If you have read the above conditions then also if you want to delete this account, then please accept the below agreement to proceed!',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Obx(
                  () => Checkbox(
                    // fillColor: MaterialStatePropertyAll(themeRedColor),
                    checkColor: Colors.white,
                    // activeColor: themeRedColor,
                    value: controller.account_delete.value,
                    onChanged: (value) {
                      print(value);
                      controller.account_delete.value = value!;
                    },
                  ),
                ),
                SizedBox(
                  width: (Get.width * 0.78) - 20,
                  child: const Text(
                      "Here i declare, that i want all my data and account to be deleted permanently!"),
                ),
              ],
            ),
            SizedBox(height: 10),
            Obx(
              () => controller.account_delete.value
                  ? ElevatedButton.icon(
                      onPressed: () {
                        controller.deleteAccount();
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Delete my profile!",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }
}

class MyBullet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 10.0,
      width: 10.0,
      decoration: new BoxDecoration(
        color: const Color.fromARGB(255, 167, 158, 158),
        shape: BoxShape.circle,
      ),
    );
  }
}
