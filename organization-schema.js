(function () {
  var script = document.createElement("script");
  script.type = "application/ld+json";
  script.textContent = JSON.stringify({
    "@context": "https://schema.org",
    "@type": "Organization",
    name: "Andi",
    alternateName: [
      "Andi AI",
      "Andi AI Search",
      "Andi Search",
      "AndiSearch",
    ],
    url: "https://andiai.com",
    logo: "https://andiai.com/images/andi-logo-black.png",
    description:
      "Andi AI is a search engine that gives you answers, not just links. Accurate, ad-free, and private.",
    foundingDate: "2021",
    sameAs: [
      "https://andisearch.com",
      "https://twitter.com/andi_search",
      "https://www.linkedin.com/company/andisearch",
      "https://github.com/andisearch",
      "https://www.reddit.com/r/AskAndi",
      "https://www.youtube.com/@andi_search",
      "https://www.instagram.com/andi_search",
      "https://www.tiktok.com/@andi_search",
      "https://www.producthunt.com/products/andi",
      "https://discord.gg/J2NJ2rj7ax",
      "https://chromewebstore.google.com/detail/bfdoibhpaoodkgapgiblgebjfohjalij",
      "https://www.crunchbase.com/organization/andi-6860",
      "https://www.ycombinator.com/companies/andi",
    ],
  });
  document.head.appendChild(script);
})();
