# Data Vault Pipeline Description - The Concept

# Introduction

Most Data Warehouse Platforms have unique properties and implementations depending on available budget, technology, types of data, types of usecases. Therefore the variety of tools for analyzing, modelling and implementing Data Warehouses ist large and will not get smaller in the future.

Even though the data vault approach provides a hugh leap to unifiy, generalize and standardize the modelling and loading of data, the toolset to implement data vault is fragmented and has mostly no interoperability.

At cimt ag we developed and adapted multiple variants of tools and frameworks to support the modelling and loading, depending on the needs and capabilities of our customers. Exchangebilty of our tools between different teams/projects was very limited. One major issue was the lack of a technology independent approach to describe the major asset, we always create: **The Data Vault Pipeline**

This concept provides a data structure with all necessary information to generate/implentend/execute a data vault loading process. The structure is independent from any technology/product but can be produced, converted an consumed by any tool, that wants to support it. This will allow tools to focus and provide excelent functional support in one specific step in the implementation process rather then to try to solve all problems of a data warehouse.

