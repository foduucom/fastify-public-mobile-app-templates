import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_view.dart';
import '../controllers/cable_assemblies_controller.dart';

class CableAssembliesView extends GetView<CableAssembliesController> {
  const CableAssembliesView({super.key});

  static const _poppins = 'Poppins';
  static const _textDark = Color(0xFF212529);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Cable assemblies',
            style: TextStyle(
              fontFamily: _poppins,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: _textDark,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: _textDark),
        ),
        body: FoduuStudioLayoutView(
          widgetList: controller.widgetList,
          isLoading: controller.isLayoutLoading,
          hasError: controller.hasError,
          errorMessage: controller.errorMessage,
          onRefresh: controller.fetchCableAssembliesLayout,
        ),
      ),
    );
  }
}
