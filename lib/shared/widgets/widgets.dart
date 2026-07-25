/// Barrel export for the app's shared widgets.
///
/// Import this single file instead of reaching into individual widget files:
///
/// ```dart
/// import 'package:loci/shared/widgets/widgets.dart';
/// ```
library;

// ── Buttons & inputs ─────────────────────────────────────────────────────────
export 'custom_button.dart';
export 'custom_dropdown.dart';
export 'custom_text_field.dart';
export 'custom_imagepicker.dart';
export 'image_picker_helper.dart';
export 'file_picker.dart';

// ── Layout & content ─────────────────────────────────────────────────────────
export 'custom_appbar.dart';
export 'custom_container.dart';
export 'custom_rich_text.dart';
export 'tittle_subtitle.dart';
export 'task_card.dart';
export 'review_card.dart';
export 'common/company_info_card.dart';

// ── Media ────────────────────────────────────────────────────────────────────
export 'custom_image_container.dart';
export 'business_avatar.dart';
export 'qrcode_maker.dart';

// ── State placeholders (loading / empty / error) ─────────────────────────────
export 'app_skeleton.dart';
export 'empty_state.dart';
export 'error_state.dart';
export 'pagination_loading.dart';

// ── Search ───────────────────────────────────────────────────────────────────
export 'MySearchDelegate.dart';
export 'paginated_search_list.dart';

// ── Feed ─────────────────────────────────────────────────────────────────────
export 'feed/post_card.dart';
export 'feed/post_comment_section.dart';
export 'feed/post_input_field.dart';
export 'feed/post_interaction_bar.dart';
export 'feed/user_post_header.dart';
export 'feed/expandable_text.dart';
export 'feed/poll_bar.dart';
export 'feed/poll_bottom_sheet.dart';
export 'feed/poll_preview.dart';
export 'feed/poll_mention_field.dart';
