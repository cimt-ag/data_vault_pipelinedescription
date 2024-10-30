Data Vault Pipeline Description (DVPD)
================================
**Concept and reference implementation**

(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)


This repository contains the documentation of the "Data Vault Description Pipeline" concept and a reference 
implementation with multiple test cases and examples.

# The concept in "3 words"
The Data Vault Pipeline Description(DPVD) defines a document syntax to describle all metadata, that is needed to 
implement a process wich loads one source object into a data vault model.

This provides a standardized interface between all steps of the implementation workflow and allows 
a decoupling 
between the tools, that are used during design and implementation. 
As a document, the DVPD also represents a 
encapsulated deployable artifact and therefore supports the implementation of automated CI/CD workflows.

Full Documentation is in this repository. 
Best start is [DVPD_Introduction_and_orientation.md](documentation%2FDVPD_Introduction_and_orientation.md)  

# Motivation
Loading data into a data warehouse is a complex task even when using the Data Vault methods, wich provide a lot of 
standardization and generalization. Many tools and frameworks try to support the modelling and implementation process.

Functions needed are: Specification of the usecase, Specification and Analysis of source data structure, Modelling 
of the Data Vault and mapping of the data, implementing the load process (fetch data from source, transform and load to 
data vault model), deployment of the processes, schedule und execute processes, monitor progress. 
All these steps contain a deep complexity by themself. A product, that supports all of these phases in an equal 
appropriate excellency and functional flexibility, is nearly impossible to implement.*

So data warehouse platforms often contain a bundle of tools with a mix of commercial products and self written code. 
One major function needed in theses workflows is the communication of the metadata, that is forged during the analysis 
and modelling steps. This metadata is needed for the implementation, and in best case can be used to generate the processing automatically. 

DVPD provides a format, to solve this problem.

 \**This product needs to solve a high varyity of scenarios, but from the perspecive of a single project, only a small amount is needed. You dont pay the price for 300 functions, when you only need 10 of them*

# What you find in this repository

### Concept Documentation
1. Description of the concept
1. Reference of the core syntax of DVPD
1. Analysis about the use case variations that should be covered by the syntax
   a. Data Mapping variation taxonomy
   a. Data Mapping dependend process generation
   a. Partitioned deletion scenarios

### Reference implementation
1. Python Implementation of DVPDC Compiler
1. Testsets
1. Python examples of generator scipts for DDL/Documentation
