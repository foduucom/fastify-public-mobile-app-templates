import 'package:get/get.dart';

class MessagesController extends GetxController {
  // Text controller for the search bar
  var searchTextController = ''.obs;

  // Mock data based on your design
  var chatList = [
    {
      'id': '1',
      'name': 'Richar Kandowen',
      'message': 'Lorem ipsum dolor sit amet...',
      'time': '10:20',
      'unread': 2,
      'isOnline': true,
      'avatar': 'https://i.pravatar.cc/150?u=1'
    },
    {
      'id': '2',
      'name': 'Jeden Murred',
      'message': 'Lorem ipsum dolor sit amet...',
      'time': '10:20',
      'unread': 2,
      'isOnline': false,
      'avatar': 'https://i.pravatar.cc/150?u=2'
    },
    {
      'id': '3',
      'name': 'Chris Offile',
      'message': 'Lorem ipsum dolor sit amet...',
      'time': '10:20',
      'unread': 0,
      'isOnline': false,
      'avatar': 'https://i.pravatar.cc/150?u=3'
    },
    {
      'id': '4',
      'name': 'Jemmy Fox',
      'message': 'Lorem ipsum dolor sit amet...',
      'time': '10:20',
      'unread': 0,
      'isOnline': false,
      'avatar': 'https://i.pravatar.cc/150?u=4'
    },
  ].obs;

  // Method to handle swipe-to-delete
  void deleteChat(String id) {
    chatList.removeWhere((chat) => chat['id'] == id);
  }
}