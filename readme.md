# Data Vault Pipeline Description (DVPD)

Concept and reference implementation

(C) Matthias Wegner, cimt ag

[![License: CC BY-ND 4.0](https://img.shields.io/badge/License-CC%20BY--ND%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nd/4.0/)
[![Version](https://img.shields.io/badge/version-0.6.2-green)]()  


## Introduction

Building Data Vault loading pipelines involves many specialized steps—source analysis, modeling, mapping, implementing load logic, deployment, scheduling, and monitoring. No single tool can cover all of this with the flexibility real projects require, so teams often combine multiple tools and custom code.
A common challenge across these components is sharing the metadata created during analysis and modeling so it can drive implementation and automation.

**DVPD was created to solve this problem.**

It provides a **universal, document-based format** to describe *all metadata needed* to implement a data-loading pipeline for a Data Vault 2.0 model. DVPD captures source-structure definitions, target-model definitions (hubs/links/satellites), field mappings, transformation parameters (e.g. hashing configuration, deletion detection, incremental loading), and all other configuration required to go from source data to a fully defined Data Vault load process.

As such, DVPD enables a **tool-independent, declarative, reproducible and automatable** definition of your data-warehouse ingestion pipeline. The repository combines the specification documentation with a **reference implementation** (in Python), including a compiler, test sets, and example generators (DDL, DBT models, model documentation, etc.).

## Why use DVPD?

- **Full Data Vault 2.0 coverage:** All object types and logic defined in the Data Vault 2.0 standard are covered by DVPD. It supports all phases of a Data Vault loading workflow, from source analysis, parsing, transformation, mapping, to load operations.
- **Standardization & decoupling:** You can avoid entangling metadata between different tools. Modeling, transformation, loading, and deployment tools can be swapped or updated independently, reducing the risks of vendor lock-in.
- **Reduced boilerplate:** Even though DVPD is expressive enough to cover complex scenarios, using it doesn’t force you to adopt a monolithic framework. You only use as much of it as your project needs.
- **CI/CD friendly:** Since DVPD is document-based and code-generators are provided, the entire process (DDL generation, schema migration, mapping changes) can be versioned, reviewed, and automated.
- **Flexibility for diverse sources & architectures:** DVPD’s syntax can describe countless source formats like tables, files (JSON/XML/CSV), API sources, and loading scenarios like incremental or full-load strategies, deletion detection logic etc.

## How to get started  

The documentation for DVPD is distributed across several articles in the [documentation](documentation/) folder. The best place to start understanding the concept is [DVPD_Introduction_and_orientation](documentation/DVPD_Introduction_and_orientation.md), which serves as an overview. For information on how use DVPD, please refer to [Installation_and_usage_of_the_reference_implementation](documentation/Installation_and_usage_of_the_reference_implementation.md).

## Support & Contribution:

This project is maintained by cimt ag. If you would like to contribute:
- Submit issues or feature requests via GitHub Issues.
- For proposed changes: fork the repo and submit a pull request.

For professional consulting support and evaluation services, see [cimt ag | IT-Consulting](https://www.cimt-ag.de/)

## License
Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)
