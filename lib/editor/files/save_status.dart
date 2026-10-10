enum SaveStatus {
  notSaved(label: 'Not saved'),
  unsavedChanges(label: 'Unsaved changes'),
  saved(label: 'Saved');

  const SaveStatus({required this.label});

  final String label;
}
