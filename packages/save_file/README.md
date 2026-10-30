# utopia_save_file

Unified and *correct* implementation of file saving.

## General behavior

1. Try to infer the MIME type and filename, if not already provided (inference not supported in `fromBytes`
   and `fromByteStream`). Fail with `SaveFileMetadataException` if not possible.
2. Check if filename has an extension matching the MIME type; if not, act according to the `extensionBehavior`
   parameter (by default, replacing the original extension).
3. Trigger the save. Wait until completion and provide the result if possible. Meanwhile, try to offload as
   much of the actual work from the Dart thread as possible.

See `fromX` methods' documentation for more details.

## Platform-specific considerations

### Android

On Android, launches system "files" app and allows user to select the destination and filename.
User can cancel the operation, in such case the `fromX` methods will complete with `SaveFileResultCancelled`.
Uses [`Intent.ACTION_CREATE_DOCUMENT`](https://developer.android.com/reference/android/content/Intent#ACTION_CREATE_DOCUMENT)
and [`ContentResolver.openInputStream`](https://developer.android.com/reference/android/content/ContentResolver#openInputStream(android.net.Uri))
under the hood.
No [`WRITE_EXTERNAL_STORAGE` permission](https://developer.android.com/reference/android/Manifest.permission#WRITE_EXTERNAL_STORAGE)
needed.
`name` parameter is only a suggestion, user can change it during saving.

### iOS

On iOS, writes the file to a private temporary directory and presents the system share sheet
([`UIActivityViewController`](https://developer.apple.com/documentation/uikit/uiactivityviewcontroller)), where
the user picks the destination ("Save to Files", AirDrop, Mail, ...). The temporary copy is deleted once the sheet is
dismissed; nothing is left in the app's Documents directory.
`fromX` methods complete with `true` when the user completed an action and `false` when the sheet was dismissed.

On iPad the share sheet is a popover. Pass `sharePositionOrigin` (global logical coordinates, usually the rect of the
tapped button) to anchor it; when omitted it is centered on the screen without an arrow:

```dart
final box = context.findRenderObject() as RenderBox;
await UtopiaSaveFile.fromBytes(
  bytes,
  name: 'report.pdf',
  mime: 'application/pdf',
  sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
);
```

No `Info.plist` configuration is needed. Versions before 0.3.0 saved to the Documents directory and required
`UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace`; these keys can be removed (they expose the whole
Documents directory in the Files app).

### macOS

On macOS, shows a save panel (`NSSavePanel`). Cancelling it completes the `fromX` methods with `false`.

### Web

On Web uses a fake [`a` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a) with the `download`
attribute to trigger the download, which then happens completely outside the app.
This causes the `fromX` methods to complete immediately with `true` (even if users later cancels the
download).
