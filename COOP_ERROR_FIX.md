# Fix Cross-Origin-Opener-Policy (COOP) Error

## Understanding the Error

**Error:** `Cross-Origin-Opener-Policy policy would block the window.closed call`

### What This Means

This error occurs when Google Sign-In tries to open a popup window for OAuth authentication, but the browser's security policy (COOP) prevents the popup from communicating with the parent window.

### Why It Happens

1. **Security Policy**: Modern browsers use COOP to prevent cross-origin attacks
2. **OAuth Popup**: Google Sign-In opens a popup window for authentication
3. **Communication Blocked**: The popup can't tell the parent window when it closes
4. **Result**: Sign-in fails silently or shows errors

## Solutions

### Solution 1: Meta Tags (Already Added) ✅

I've added meta tags to `web/index.html`:
```html
<meta http-equiv="Cross-Origin-Opener-Policy" content="same-origin-allow-popups">
<meta http-equiv="Cross-Origin-Embedder-Policy" content="unsafe-none">
```

**Note:** Meta tags work for some cases, but server headers are more reliable.

### Solution 2: Server Configuration

#### For Apache (.htaccess)
I've created `web/.htaccess` with the proper headers.

#### For IIS (web.config)
I've created `web/web.config` with the proper headers.

#### For Development Server (Flutter)

When running `flutter run -d chrome`, Flutter uses its own development server. The meta tags should help, but you may need to:

1. **Use Chrome with flags** (temporary fix):
   ```bash
   chrome --disable-features=CrossOriginOpenerPolicy
   ```

2. **Or use a different browser** for testing (Firefox, Edge)

### Solution 3: Alternative - Use Redirect Instead of Popup

If popup continues to fail, we can modify Google Sign-In to use redirect flow instead. This requires:
- Updating the OAuth flow
- Handling redirect callbacks
- More complex implementation

## Quick Fix for Development

### Option 1: Run Chrome with Disabled COOP
```bash
# Windows
chrome.exe --disable-features=CrossOriginOpenerPolicy --user-data-dir="C:/temp/chrome_dev"

# Then run Flutter
flutter run -d chrome --web-port=3000
```

### Option 2: Use Firefox or Edge
These browsers may handle COOP differently:
```bash
flutter run -d firefox --web-port=3000
# or
flutter run -d edge --web-port=3000
```

### Option 3: Test in Production Build
Sometimes the issue only occurs in development:
```bash
flutter build web
# Then serve with a proper web server that sends headers
```

## Production Deployment

For production, ensure your web server sends these headers:

**Apache (.htaccess):**
```apache
Header set Cross-Origin-Opener-Policy "same-origin-allow-popups"
Header set Cross-Origin-Embedder-Policy "unsafe-none"
```

**Nginx:**
```nginx
add_header Cross-Origin-Opener-Policy "same-origin-allow-popups";
add_header Cross-Origin-Embedder-Policy "unsafe-none";
```

**Node.js/Express:**
```javascript
app.use((req, res, next) => {
  res.setHeader('Cross-Origin-Opener-Policy', 'same-origin-allow-popups');
  res.setHeader('Cross-Origin-Embedder-Policy', 'unsafe-none');
  next();
});
```

## Verification

After applying fixes:

1. **Clear browser cache**
2. **Hard refresh** (Ctrl+Shift+R or Cmd+Shift+R)
3. **Check browser console** - COOP errors should be gone
4. **Try Google Sign-In** - should work without errors

## Still Having Issues?

If errors persist:

1. **Check browser console** for specific error messages
2. **Verify Google Cloud Console** configuration (redirect URIs)
3. **Try incognito mode** to rule out extensions
4. **Check if popup is being blocked** by browser settings
5. **Consider using redirect flow** instead of popup (more complex but more reliable)

## Technical Details

**COOP Values:**
- `same-origin`: Strictest, blocks all cross-origin popups
- `same-origin-allow-popups`: Allows popups from same origin (what we need)
- `unsafe-none`: No restrictions (less secure, but works for development)

**COEP Values:**
- `unsafe-none`: No restrictions (what we're using)
- `require-corp`: Requires cross-origin resources to opt-in (too strict for OAuth)

For Google Sign-In OAuth popups, `same-origin-allow-popups` + `unsafe-none` is the recommended combination.

