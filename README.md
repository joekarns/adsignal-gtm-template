# AdSignal Tracking Pixel — Google Tag Manager Template

Official GTM Community Template for the [AdSignal](https://www.flb7.com) tracking pixel. Installs the AdSignal pixel and fires a pageview event on every tag execution.

## What It Does

- Loads the AdSignal pixel script (`p.js`) from `pixel.flb7.com`
- Initializes the pixel with your Pixel ID
- Automatically tracks a pageview event
- Captures UTM parameters, ad platform click IDs, referrer, and screen resolution
- Assigns persistent visitor IDs and session IDs for attribution

## Installation

### From the Community Template Gallery

1. In your GTM container, go to **Templates** > **Tag Templates** > **Search Gallery**
2. Search for **AdSignal Tracking Pixel**
3. Click **Add to workspace**

### Manual Import

1. Download `template.tpl` from this repository
2. In GTM, go to **Templates** > **Tag Templates** > **New**
3. Click the three-dot menu (⋮) > **Import**
4. Select the `template.tpl` file

## Setup

1. Create a new **Tag** in your GTM workspace
2. Choose **AdSignal Tracking Pixel** as the tag type
3. Enter your **Pixel ID** (e.g. `px_abc123`) — find this in your [AdSignal dashboard](https://app.flb7.com) under **Pixel Setup**
4. Set the trigger to **All Pages** (or whichever pages you want to track)
5. Save and publish

## Pixel ID

Your Pixel ID is a unique identifier that starts with `px_`. You can find it in the AdSignal dashboard:

1. Log in at [app.flb7.com](https://app.flb7.com)
2. Navigate to **Pixel Setup**
3. Copy your Pixel ID

## Conversion Tracking

This template handles pageview tracking. For conversion and custom event tracking, create a **Custom HTML** tag with:

```html
<script>
  window._as = window._as || [];
  window._as.push({
    type: "conversion",
    conversion_type: "purchase",
    conversion_value: 99.99,
    conversion_id: "order-12345"
  });
</script>
```

## Custom Events

```html
<script>
  window._as = window._as || [];
  window._as.push({
    type: "custom",
    custom_event: "signup_complete",
    custom_data: { plan: "pro" }
  });
</script>
```

## Permissions

This template requires the following GTM sandboxed permissions:

| Permission | Scope | Reason |
|---|---|---|
| `inject_script` | `https://pixel.flb7.com/p.js` | Load the pixel script |
| `access_globals` | `_as` (read/write), `adsignal` (read/execute) | Initialize and call the pixel API |
| `logging` | debug mode only | Log status messages in GTM preview mode |

## License

Apache 2.0 — see [LICENSE](LICENSE).
