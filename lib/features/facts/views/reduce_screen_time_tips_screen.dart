import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lockin/core/routes/routes.dart';
import 'package:lockin/core/widgets/custom_button.dart';
import 'package:lockin/features/facts/models/reduce_time_model.dart';
import 'package:lockin/features/facts/view_models/reduce_time_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReduceScreenTimeTipsScreen extends StatelessWidget {
  final bool isPositive;

  const ReduceScreenTimeTipsScreen({super.key, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TipsViewModel(isPositive: isPositive),
      child: Scaffold(
        appBar: AppBar(title: Text('tips_screen.app_bar_title'.tr())),
        body: const _TipsBody(),
      ),
    );
  }
}

/* ─────────────────────────────── */
/* TIPS BODY */
/* ─────────────────────────────── */
class _TipsBody extends StatelessWidget {
  const _TipsBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<TipsViewModel>(
      builder: (context, viewModel, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSection(
                visible: viewModel.visible[0],
                header: viewModel.header,
              ),
              SizedBox(height: 32.h),
              _TipsList(
                tips: viewModel.tips,
                visibleStates: viewModel.visible.sublist(
                  1,
                  viewModel.tips.length + 1,
                ),
              ),
              SizedBox(height: 32.h),
              _ClosingSection(
                visible: viewModel.visible.last,
                closingMessage: viewModel.closingMessage,
              ),
              SizedBox(height: 32.h),
              _BackHomeButton(),
            ],
          ),
        );
      },
    );
  }
}

/* ─────────────────────────────── */
/* HEADER SECTION */
/* ─────────────────────────────── */
class _HeaderSection extends StatelessWidget {
  final bool visible;
  final String header;

  const _HeaderSection({required this.visible, required this.header});

  @override
  Widget build(BuildContext context) {
    return _AnimatedBlock(
      visible: visible,
      child: Text(header, style: Theme.of(context).textTheme.headlineLarge),
    );
  }
}

/* ─────────────────────────────── */
/* TIPS LIST */
/* ─────────────────────────────── */
class _TipsList extends StatelessWidget {
  final List<TipModel> tips;
  final List<bool> visibleStates;

  const _TipsList({required this.tips, required this.visibleStates});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        tips.length,
        (index) => _AnimatedBlock(
          visible: visibleStates[index],
          child: _TipItem(item: tips[index]),
        ),
      ),
    );
  }
}

/* ─────────────────────────────── */
/* CLOSING SECTION */
/* ─────────────────────────────── */
class _ClosingSection extends StatelessWidget {
  final bool visible;
  final String closingMessage;

  const _ClosingSection({required this.visible, required this.closingMessage});

  @override
  Widget build(BuildContext context) {
    return _AnimatedBlock(
      visible: visible,
      child: Text(
        closingMessage,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.6),
      ),
    );
  }
}

/* ─────────────────────────────── */
/* BACK HOME BUTTON */
/* ─────────────────────────────── */
class _BackHomeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: "Back Home",
      onPressed: () => Navigator.pushReplacementNamed(context, Routes.home),
    );
  }
}

/* ─────────────────────────────── */
/* ANIMATED BLOCK */
/* ─────────────────────────────── */
class _AnimatedBlock extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _AnimatedBlock({required this.visible, required this.child});

  static const _animationDuration = Duration(milliseconds: 600);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: _animationDuration,
      curve: Curves.easeOut,
      opacity: visible ? 1 : 0,
      child: AnimatedSlide(
        duration: _animationDuration,
        curve: Curves.easeOut,
        offset: visible ? Offset.zero : const Offset(0, 0.06),
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: child,
        ),
      ),
    );
  }
}

/* ─────────────────────────────── */
/* TIP ITEM */
/* ─────────────────────────────── */
class _TipItem extends StatelessWidget {
  final TipModel item;

  const _TipItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(item.icon, size: 28.sp),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            item.text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }
}
