# ecqm-content-qicore-2022
eCQM Measure Content (Using QICore 4.1.1, based on FHIR R4 v4.0.1)

These draft FHIR-based measures and shared libraries are translated from the QDM-based versions of eCQMs to be published in May 2022 for the 2023 reporting year, and have specific versions, especially for the shared libraries, appropriate to the content for that publication update.

Commits to this repository will automatically trigger a build of the continuous integration build, available here:

https://build.fhir.org/ig/cqframework/ecqm-content-qicore-2022

## Authoring

To author content in this implementation guide, you can use either the Atom CQL Plugin, or the VS Code CQL Plugin. Both plugins will enable you to author, validate, and execute FHIR-based eCQM content.

NOTE: The Atom Editor is being sunsetted, as such we recommend use of the VS Code Plugin
For instructions on setting up your environment to use the Atom CQL Plugin, see the [Atom CQL Support Readme](https://github.com/cqframework/atom_cql_support/blob/master/README.md).

For instructions on setting up your environment to use the VS Code Plugin, see the [VS Code CQL Support Readme](https://github.com/cqframework/vscode-cql/blob/master/README.md)

## Content Index

The following table provides an index to the currently available library content in this implementation guide:

### Shared Libraries

|Library|Version|Status|Development Status|
|----|----|----|----|
|[AdultOutpatientEncountersQICore4](input/cql/AdultOutpatientEncountersQICore4.cql)|2.0.000|Active|TODO|
|[AdvancedIllnessandFrailtyExclusionQiCore4](input/cql/AdvancedIllnessandFrailtyExclusionQICore4.cql)|5.0.000|Active|TODO|
|[CumulativeMedicationDurationQICore4](input/cql/CumulativeMedicationDurationQICore4.cql)|2.0.000|Active|Converted|
|[FHIRCommon](input/cql/FHIRCommon.cql)|4.0.012|Active|Converted|
|[FHIRHelpers](input/cql/FHIRHelpers.cql)|4.0.012|Active|Converted|
|[HospiceQICore4](input/cql/HospiceQICore4.cql)|2.0.000|Active|TODO|
|[MATGlobalCommonFunctionsQICore4](input/cql/MATGlobalCommonFunctionsQICore4.cql)|7.0.000|Active|Converted|
|[SupplementalDataElementsQICore4](input/cql/SupplementalDataElementsQICore4.cql)|3.0.000|Active|Converted|

### Measure Libraries

// TODO: Update these with content from the 2022 AU publication packages

|Library|Version|Status|Development Status|
|----|----|----|----|
|[EXM124v7QICore4](input/cql/EXM124v7QICore4.cql)|7.0.000|Draft|TODO|
|[EXM165v8QICore4](input/cql/EXM165v8QICore4.cql)|8.5.000|Draft|TODO|

## Repository Structure

It is setup like any HL7 FHIR IG project but also includes the CQL files and test data which means the file structure will be as follows:

```
   |-- _genonce.bat
   |-- _genonce.sh
   |-- _refresh.bat
   |-- _refresh.sh
   |-- _updatePublisher.bat
   |-- _updatePublisher.sh
   |-- _updateCQFTooling.bat
   |-- _updateCQFTooling.sh
   |-- ig.ini
   |-- bundles
       |-- MAT
           |--EXM124bundle files
       |-- measure
           |--EXM124
   |-- input
       |-- ecqm-content-qicore-2020.xml
       |-- cql
           |-- EXM124.cql
       |-- pagecontent
       |-- resources
           |-- library
               |-- EXM124.json
           |-- measure
               |-- EXM124.json
       |-- tests
           |-- measure
               |-- EXM124
                   |-- denom-EXM124
                   |-- ...
       |-- vocabulary
           |-- valueset
```

## Extracting MAT Packages

The CQF Tooling provides support for extracting a MAT exported package into the
directories of this repository so that the measure is included in the published
implementation guide. To do this, place the MAT export files (unzipped) in a
directory in the `bundles\mat` directory, and then run the following tooling
command:

```
[tooling-jar] -ExtractMatBundle bundles\mat\[bundle-directory]\[bundle-file]
```

For example:

```
input-cache\tooling-1.3.1-SNAPSHOT-jar-with-dependencies.jar -ExtractMATBundle bundles\mat\CLONE124_v6_03-Artifacts\measure-json-bundle.json
```

## Refresh IG Processing

The CQF Tooling provides "refresh" tooling that performs the following functions:

* Translates and validates all CQL source files
* Packages CQL and ELM content in the corresponding FHIR resources
* Refreshes generated content for each knowledge artifact (Library, Measure, PlanDefinition, ActivityDefinition) including parameters, dependencies, and effective data requirements

Then run the `_refresh` command to refresh the implementation guide content with the new content, and then run `_genonce` to run the publication tooling on the implementation guide (the same process that the continuous integration build uses to publish the implementation guide when commits are made to this repository).
