import 'package:flutter/material.dart';

class ComboboxBuscador<T extends Object> extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final List<T> items;
  final String Function(T item) itemLabel;
  final T? initialItem;
  final ValueChanged<T> onSelected;
  final String? Function(String?)? validator;

  const ComboboxBuscador({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.items,
    required this.itemLabel,
    this.initialItem,
    required this.onSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      initialValue: TextEditingValue(
        text: initialItem != null ? itemLabel(initialItem!) : '',
      ),
      displayStringForOption: itemLabel,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.trim().isEmpty) {
          return items;
        }
        return items.where((item) => itemLabel(item)
            .toLowerCase()
            .contains(textEditingValue.text.trim().toLowerCase()));
      },
      onSelected: onSelected,
      optionsViewBuilder: (context, onSelectedOption, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180, maxWidth: 280),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final T option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      itemLabel(option),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () => onSelectedOption(option),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            prefixIcon: Icon(prefixIcon),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: const OutlineInputBorder(),
          ),
          validator: validator ??
              (val) {
                if (val == null || val.trim().isEmpty) {
                  return '$label es obligatorio.';
                }
                final exists = items.any((item) =>
                    itemLabel(item).toLowerCase() == val.trim().toLowerCase());
                if (!exists) {
                  return 'Opción no válida. Seleccione una de la lista.';
                }
                return null;
              },
          onChanged: (val) {
            final match = items.where((item) =>
                itemLabel(item).toLowerCase() == val.trim().toLowerCase());
            if (match.isNotEmpty) {
              onSelected(match.first);
            }
          },
        );
      },
    );
  }
}
