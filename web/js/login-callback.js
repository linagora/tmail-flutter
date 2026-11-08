const AUTH_DESTINATION_KEY = "auth_destination_url";
    const AUTH_RESPONSE_KEY = "auth_info";

    /** Show a retry link and discard the failed OAuth transaction. */
    function showFailure() {
      document.title = "Sign-in failed";
      document.getElementById("failure").hidden = false;
      document.getElementById("retry").href = new URL(".", location.href).href;
      try {
        for (const key of [AUTH_DESTINATION_KEY, AUTH_RESPONSE_KEY,
                           "auth_code_verifier", "auth_request_state"]) {
          sessionStorage.removeItem(key);
        }
      } catch (_) {
        // Storage can be disabled; keep the retry link usable in that case.
      }
    }

    /** Validate the callback before handing it to the authentication plugin. */
    window.onload = function () {
      let operation = "read-storage";
      try {
        const callback = new URL(location.href);
        const response = callback.searchParams;
        const pendingState = sessionStorage.getItem("auth_request_state");
        const verifier = sessionStorage.getItem("auth_code_verifier");
        // Older plugin versions do not generate state. If either side has
        // state, require a complete matching transaction; otherwise preserve
        // the legacy callback until the plugin's state support is adopted.
        const hasState = pendingState !== null || response.has("state");
        const invalidState = hasState &&
            (response.getAll("state").length !== 1 || !response.get("state") ||
             !pendingState || response.get("state") !== pendingState);
        // An error callback must stop here. Sending it back to the dashboard
        // starts another automatic sign-in and hides the provider's failure.
        if (response.has("error") || callback.href.includes("#") ||
            response.getAll("code").length !== 1 || !response.get("code") ||
            invalidState || !verifier) {
          showFailure();
          return;
        }

        // Get the original page destination
        const destination = sessionStorage.getItem(AUTH_DESTINATION_KEY) || "/";
        operation = "remove-destination";
        sessionStorage.removeItem(AUTH_DESTINATION_KEY);

        // Store the current window location that will be used to get the information for authentication
        operation = "store-response";
        sessionStorage.setItem(AUTH_RESPONSE_KEY, window.location);

        // Build the redirect URL
        let redirectUrl;
        if (destination.includes("/login")) {
          redirectUrl = destination.replace("/login", "/dashboard?type=normal");
        } else {
          const separator = destination.endsWith("/") ? "" : "/";
          redirectUrl = destination + separator + "dashboard?type=normal";
        }

        // Perform redirection
        operation = "redirect";
        location.assign(redirectUrl);
      } catch (error) {
        console.error(`[Auth Redirect] Sign-in failed during ${operation}.`);
        showFailure();
      }
    };
