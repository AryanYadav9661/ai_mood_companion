import 'package:flutter/material.dart';

class MoodPicker extends StatefulWidget {
  final void Function(int value) onChanged;
  const MoodPicker({super.key, required this.onChanged});
  @override
  State<MoodPicker> createState() => _MoodPickerState();
}

class _MoodPickerState extends State<MoodPicker> {
  int? _selected;
  final emojis = const ['😞','🙁','😐','🙂','😀'];
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:
      List.generate(5, (i) {
        final idx = i+1;
        final isSel = _selected == idx;
        return InkWell(onTap: () { setState(()=>_selected = idx); widget.onChanged(idx); }, borderRadius: BorderRadius.circular(18), child:
          AnimatedContainer(duration: const Duration(milliseconds:180), padding: const EdgeInsets.symmetric(horizontal:14, vertical:10), transform: Matrix4.identity()..scale(isSel?1.08:1.0), decoration: BoxDecoration(color: isSel?Theme.of(context).colorScheme.primaryContainer:null, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)), child: Text('\${emojis[i]}\n\${idx.toString()}', textAlign: TextAlign.center))
        );
      })
    );
  }
}
