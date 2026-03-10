import 'package:flutter/cupertino.dart';
import 'package:loci/presentation/pages/home/widgets/poll_bar.dart';

import '../../../../data/poll.dart';


class PostPollSection extends StatelessWidget {
  final List<PollOption> options;

  const PostPollSection({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
       clipBehavior: Clip.antiAlias,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final opt = options[index];
        return PollBar(
          title: opt.title,
          percent: opt.percent,
          imagePath: opt.imagePath,
        //  trailingText: opt.trailingText,
        );
      },
    );
  }
}