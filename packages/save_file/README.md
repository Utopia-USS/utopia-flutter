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

On iOS, saves to application documents directory, but files will be visible in system "Files" app (due to
the [`UIFileSharingEnabled` property](https://developer.apple.com/documentation/bundleresources/information_property_list/uifilesharingenabled))
Does not require any user interaction, so `fromX` methods will always return `true`.

#### Configuration

Add to `Info.plist`:

```
<key>NSAllowsArbitraryLoads</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UIFileSharingEnabled</key>
<true/>
```

### Web

On Web uses a fake [`a` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a) with the `download`
attribute to trigger the download, which then happens completely outside the app.
This causes the `fromX` methods to complete immediately with `true` (even if users later cancels the
download).
