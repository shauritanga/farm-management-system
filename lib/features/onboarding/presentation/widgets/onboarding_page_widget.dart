import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/onboarding_page.dart';
import 'onboarding_image_widget.dart';
import '../../../../core/utils/responsive_utils.dart';

// class OnboardingPageWidget extends StatelessWidget {
//   final OnboardingPageEntity page;
//   final VoidCallback? onButtonPressed;

//   const OnboardingPageWidget({
//     super.key,
//     required this.page,
//     this.onButtonPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Padding(
//       padding: ResponsiveUtils.paddingAll24,
//       child: Column(
//         children: [
//           // Image
//           Expanded(flex: 3, child: OnboardingImageWidget(page: page)),

//           SizedBox(height: ResponsiveUtils.height24),

//           // Content
//           Expanded(
//             flex: 2,
//             child: Column(
//               children: [
//                 // Title
//                 Text(
//                   page.title,
//                   style: GoogleFonts.poppins(
//                     fontSize: ResponsiveUtils.fontSize28,
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                     height: 1.2,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),

//                 SizedBox(height: ResponsiveUtils.height16),

//                 // Description
//                 Text(
//                   page.description,
//                   style: GoogleFonts.inter(
//                     fontSize: ResponsiveUtils.fontSize16,
//                     color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
//                     height: 1.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),

//                 const Spacer(),

//                 // Button (only on last page)
//                 if (page.buttonText != null) ...[
//                   SizedBox(
//                     width: double.infinity,
//                     height: ResponsiveUtils.buttonHeightExtraLarge,
//                     child: ElevatedButton(
//                       onPressed: onButtonPressed,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: theme.colorScheme.primary,
//                         foregroundColor: theme.colorScheme.onPrimary,
//                         elevation: 2,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                             ResponsiveUtils.radius16,
//                           ),
//                         ),
//                       ),
//                       child: Text(
//                         page.buttonText!,
//                         style: GoogleFonts.poppins(
//                           fontSize: ResponsiveUtils.fontSize18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: ResponsiveUtils.height20),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageEntity page;
  final VoidCallback? onButtonPressed;

  const OnboardingPageWidget({
    super.key,
    required this.page,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: ResponsiveUtils.paddingAll24,
        child: Column(
          children: [
            SizedBox(height: ResponsiveUtils.height24),
            AspectRatio(
              aspectRatio: 1, // Adjust based on image needs
              child: OnboardingImageWidget(page: page),
            ),
            SizedBox(height: ResponsiveUtils.height24),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  page.title,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveUtils.height16),
                Text(
                  page.description,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveUtils.height8),
                if (page.buttonText != null) ...[
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUtils.buttonHeightExtraLarge,
                    child: ElevatedButton(
                      onPressed: onButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 2,
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.radius16,
                          ),
                        ),
                      ),
                      child: Text(
                        page.buttonText!,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.fontSize18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.height20),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
