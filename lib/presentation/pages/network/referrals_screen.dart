import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/status.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';

import '../../widgets/referral_card.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Referrals',
          style: AppTextStyle.textLg(weight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Search Bar
              CustomTextField(
                hintText: "Search Referral ..",
                suffixIcon: Icon(Icons.search, color: context.colorScheme.onSurfaceVariant),
                textColor: context.colorScheme.onSurface,
                borderColor: context.colorScheme.outline,
              ),
              const SizedBox(height: 20),
              Text("Referrals", style: AppTextStyle.textXl(weight: FontWeight.w600)),
              const SizedBox(height: 5,),
              Text(
                "Manage your business referrals",
                style: AppTextStyle.textSm(color: context.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
        
              // Send New Referral Button
              CustomButton(
                backgroundColor: context.colorScheme.primary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
        
                    Icon(Icons.send_outlined, color: context.colorScheme.onPrimary),
                    const SizedBox(width: 8),
                    Text(
                      "Send New Referral",
                      style: AppTextStyle.textMd(weight: FontWeight.w600,color: context.colorScheme.onPrimary),
                    ),
        
                  ],
                ),
                onPressed: (){},
        
        
              ),
              const SizedBox(height: 20),
        
              // Referral List

              ListView.separated(
                shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 4,

                  itemBuilder: (context,index){
                    return  const ReferralCard(
                      status: ReferralStatus.pending,
                      fromName: "Saraa Johnson", // Removed the duplicate line
                      fromCompany: "TechCorp",
                      toName: "Michael Chen",
                      toCompany: "Innovate Labs",
                      message: "Michael would be a great fit for your enterprise sales team!",
                      date: "Jan 12, 2026",
                    );
        
              }, separatorBuilder: (BuildContext context, int index) { return SizedBox(height: 15,); },),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPersonInfo(String name, String company) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: AppTextStyle.textSm(weight: FontWeight.w600,color: context.colorScheme.onSurface)),
        Text(company, style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant)),
      ],
    );
  }




}