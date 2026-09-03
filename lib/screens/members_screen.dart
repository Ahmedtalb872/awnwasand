import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/member.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  bool _showAffiliates = false;

  @override
  Widget build(BuildContext context) {
    final list = _showAffiliates ? MockData.affiliates : MockData.members;

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(title: const Text('الأعضاء والمنتسبين')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardLight,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.borderLight),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _Segment(
                        label: 'الأعضاء',
                        selected: !_showAffiliates,
                        onTap: () => setState(() => _showAffiliates = false),
                      ),
                    ),
                    Expanded(
                      child: _Segment(
                        label: 'المنتسبين',
                        selected: _showAffiliates,
                        onTap: () => setState(() => _showAffiliates = true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _MemberTile(member: list[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: PrimaryButton(
                label: 'عرض جميع الأعضاء',
                color: AppColors.navy,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textGray,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final AssociationMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.borderLight,
            child: Icon(Icons.person, color: AppColors.navySoft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.role,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textGray, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
