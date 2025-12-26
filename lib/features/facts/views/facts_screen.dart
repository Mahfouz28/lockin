import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../view_models/facts_viewmodel.dart';

class FactsScreen extends StatelessWidget {
  const FactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FactsViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Facts', style: TextStyle(fontSize: 18.sp)),
        ),
        body: Consumer<FactsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
                child: Text(
                  viewModel.error!,
                  style: TextStyle(color: Colors.red, fontSize: 16.sp),
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Facts Feature', style: TextStyle(fontSize: 24.sp)),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: viewModel.loadData,
                    child: Text('Load Data', style: TextStyle(fontSize: 16.sp)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
