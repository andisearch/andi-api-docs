(function () {
  var script = document.createElement("script");
  script.async = true;
  script.src = "https://us-assets.i.posthog.com/static/array.js";
  script.onload = function () {
    posthog.init("phc_afElmpLLyofAdfYVvGJJYmSShyMjX8uMOHtGaaKolOe", {
      api_host: "https://us.i.posthog.com",
      person_profiles: "always",
      capture_pageview: true,
      capture_pageleave: true,
    });
  };
  document.head.appendChild(script);
})();
