# Open Taxonomy: Bringing LLM Understanding to the World's Products

<p align="center"><img src="./docs/assets/img/header.png" /></p>

<h1 align="center">Open Taxonomy <img src="https://img.shields.io/badge/preview-orange.svg" alt="Preview"> <a href="./VERSION"><img src="https://img.shields.io/badge/version-vUNRELEASED-orange.svg" alt="Version"></a></h1>

**🌍 Global Standard**: Building upon Shopify's open-source, standardized product taxonomy to create an extended universal language for product classification, empowering merchants and developers alike.

**👩🏼‍💻 Integration Friendly**: Designed with a stable structure and diverse formats for effortless integration into any system.

**🚀 Industry Benchmark**: Covering a wide array of manufactured products, Open Taxonomy offers extensive categories, attributes, and values, facilitating comprehensive classification.

<p align="right"><em>Learn more about the original project on <a href="https://help.shopify.com/manual/products/details/product-category">help.shopify.com</a></em></p>

## 🗂️ Table of Contents

- [Open Taxonomy: Bringing LLM Understanding to the World's Products](#open-taxonomy-bringing-llm-understanding-to-the-worlds-products)
  - [🗂️ Table of Contents](#️-table-of-contents)
  - [🕹️ Interactive Explorer](#️-interactive-explorer)
  - [📚 Taxonomy Overview](#-taxonomy-overview)
  - [🧭 Getting Started](#-getting-started)
    - [🧩 How to Integrate with the Taxonomy](#-how-to-integrate-with-the-taxonomy)
    - [🧑🏼‍🏫 How to Make Changes to the Taxonomy](#-how-to-make-changes-to-the-taxonomy)
    - [👩🏼‍💻 How to Evolve the System](#-how-to-evolve-the-system)
  - [🤿 Diving In](#-diving-in)
  - [🛠️ Setup and Dependencies](#️-setup-and-dependencies)
    - [For users with `minidev`:](#for-users-with-minidev)
    - [For others:](#for-others)
  - [📂 How This Is All Organized](#-how-this-is-all-organized)
  - [🧑‍💻 Contributing](#-contributing)
  - [📅 Releases](#-releases)
  - [📜 License](#-license)
  - [TODO List](#todo-list)

## 🕹️ Interactive Explorer

Ready to dive in? [Explore our taxonomy interactively](https://intuitive-systems.github.io/open-taxonomy/releases/unstable/?categoryId=gid%3A%2F%2Fopen-taxonomy%2FTaxonomyCategory%2Fel-6-3) to visualize and discover the extensive categories, attributes, and values.

## 📚 Taxonomy Overview

Open Taxonomy is an open-source extension of Shopify's comprehensive, global standard for product classification. This project aims to provide an enhanced taxonomy for a variety of manufactured products, along with code abstractions that enable LLM agents to interact with and create their own taxonomies.

## 🧭 Getting Started

This repository is the home of Open Taxonomy. It houses the source-of-truth data, distribution files for implementation, and the source code that powers the taxonomy system.

We've structured it to be as user-friendly as possible, whether you're looking to integrate the taxonomy into your system, suggest changes, or delve into how it's developed and maintained.

### 🧩 How to Integrate with the Taxonomy

Head to the [`dist`](./dist/) directory to find the files you need and integrate this taxonomy into your system. Currently available in `txt` and `json` formats, with more on the way. If you need a specific format, please open an issue to let us know!

### 🧑🏼‍🏫 How to Make Changes to the Taxonomy

> **🔵 Note**: While in preview, we are not actively seeking PRs.

All source-of-truth data is located in the [`data/`](./data) directory. Submit PRs here to propose changes to the taxonomy.

### 👩🏼‍💻 How to Evolve the System

Beyond the data, you'll find the tools we use to manage the taxonomy and generate distributions. This is where the system evolves and improves.

## 🤿 Diving In

This project is built as a simple Ruby app with models and serializers. It parses the data in `data/` into a structured format, stored in `app/models/category.rb`, and then serializes it to `dist/`. The app follows a Rails-like structure and uses `ActiveRecord`.

Primary commands include:

```sh
make [build] # Build the dist and documentation files
make clean   # Remove sentinels and all generated files
make seed    # Parse data/ into the local database
make test    # Run Ruby tests and cue schema verification
make server  # Start the interactive view at http://localhost:4000
```

## 🛠️ Setup and Dependencies

### For users with [`minidev`](https://github.com/burke/minidev):
- Run `dev up`

### For others:
- Install `ruby`, matching the version in `.ruby-version`
- Install [`cue`](https://github.com/cue-lang/cue?tab=readme-ov-file#download-and-install), version 0.7.x or higher
- Install `make`
- Run `bundle install`

Note: For users with MacOS, make sure your XCode Command Line Tools are installed and up to date. You can do this by running `xcode-select --install` in your terminal.

When editing cue files, run `cue fmt` to format them correctly.

## 📂 How This Is All Organized

If you're diving deeper, here's a quick guide:

```
./
├── application.rb       # Handles file loading "app-wide"
├── Makefile             # Primary source of useful commands
├── Rakefile             # Only used for testing
├── app/
│   ├── models/          # Simple data object models
│   │   ├── category.rb  # Node-based tree implementation for categories
│   └── serializers/
│       ├── source_data/ # For reading/writing source data files
│       ├── docs/        # For generating documentation
│       └── dist/        # File-type-centric, one file per distribution type
├── bin/
│   ├── generate_dist    # Main entry point for generating dist/
│   └── generate_docs    # Main entry point for generating docs/
├── db/
│   ├── schema.rb        # Defines tables for models
│   └── seed.rb          # Seeds the database from data/
├── data/
│   ├── integrations/    # Integrations and mappings between taxonomies
│   ├── localizations/   # Localizations for categories, attributes, and values
│   ├── categories/      # Source-of-truth for categories
│   ├── attributes.yml   # Source-of-truth for attributes
│   └── values.yml       # Source-of-truth for values
└── test/
```

## 🧑‍💻 Contributing

We welcome contributions! However, PRs will be delayed until the Open Taxonomy approaches a `STABLE` release.

## 📅 Releases

You can find the current published version in [`VERSION`](./VERSION). The changelog is available in [`CHANGELOG.md`](./CHANGELOG.md).

We use SemVer for versioning while in the preview stage. Upon stabilization, we'll transition to [CalVer](https://calver.org/) in sync with [Shopify's API release schedule](https://shopify.dev/docs/api/usage/versioning#release-schedule).

Formal releases are published as GitHub releases and available on the [interactive docs site](https://shopify.github.io/product-taxonomy/).

## 📜 License

Open Taxonomy is released under the [MIT License](./LICENSE). Explore, play, and build something awesome!

## TODO List
- [ ] Add support attribute descriptions 
- [ ] Add support for category descriptions
- [ ] Add support for dynamic taxonomy construction based on a list of products from an existing taxonomy 
- [ ] Add MVP HP and Lenovo Manufacture Name Taxonomies
- [ ] Add support for disjointed Category Links (for linking to Manufacture naming taxonomies)