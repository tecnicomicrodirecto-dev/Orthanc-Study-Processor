------------------------------------------------------------------------------
-- OSP - Orthanc Study Processor
--
-- File:
--     foundation/constants.lua
--
-- Purpose:
--     Defines every immutable constant used throughout OSP.
--
-- Notes:
--     This module contains no executable logic.
--     All values defined here are considered read-only.
--
------------------------------------------------------------------------------

local M = {}

------------------------------------------------------------------------------
-- Application
------------------------------------------------------------------------------

M.Application = {

    Name = "Orthanc Study Processor",

    ShortName = "OSP",

    Version = "2.0.0",

    Build = "Development"

}

------------------------------------------------------------------------------
-- Metadata Keys
--
-- Numeric values are reserved according to the workflow design.
------------------------------------------------------------------------------

M.Metadata = {

    WorkflowVersion = 1027,

    OriginalStudyUID = 1028

}

------------------------------------------------------------------------------
-- Workflow States
------------------------------------------------------------------------------

M.Workflow = {

    Created      = "CREATED",

    Loading      = "LOADING",

    Formatting   = "FORMATTING",

    Metadata     = "METADATA",

    Exporting    = "EXPORTING",

    Archiving    = "ARCHIVING",

    Reimporting  = "REIMPORTING",

    Cleaning     = "CLEANING",

    Completed    = "COMPLETED",

    Failed       = "FAILED"

}

------------------------------------------------------------------------------
-- Logging
------------------------------------------------------------------------------

M.Logging = {

    Debug   = "DEBUG",

    Info    = "INFO",

    Warning = "WARNING",

    Error   = "ERROR"

}

------------------------------------------------------------------------------
-- Workspace
------------------------------------------------------------------------------

M.Workspace = {

    Raw       = "Raw",

    Working   = "Working",

    Export    = "Export",

    Archive   = "Archive",

    Temp      = "Temp",

    Logs      = "Logs"

}

------------------------------------------------------------------------------
-- Export
------------------------------------------------------------------------------

M.Export = {

    DicomDirectory = "Dicom",

    ZipDirectory   = "Zip",

    ZipExtension   = ".zip"

}

------------------------------------------------------------------------------
-- DICOM Tags
--
-- Only tags used directly by OSP should be listed here.
------------------------------------------------------------------------------

M.Dicom = {

    PatientName          = "PatientName",

    PatientID            = "PatientID",

    PatientBirthDate     = "PatientBirthDate",

    PatientSex           = "PatientSex",

    StudyInstanceUID     = "StudyInstanceUID",

    StudyDescription     = "StudyDescription",

    StudyDate            = "StudyDate",

    StudyTime            = "StudyTime",

    SeriesDescription    = "SeriesDescription",

    SeriesNumber         = "SeriesNumber",

    SeriesInstanceUID    = "SeriesInstanceUID",

    SOPInstanceUID       = "SOPInstanceUID",

    InstanceNumber       = "InstanceNumber",

    BodyPartExamined     = "BodyPartExamined",

    Modality             = "Modality",

    AccessionNumber      = "AccessionNumber"

}

------------------------------------------------------------------------------
-- Orthanc REST Endpoints
------------------------------------------------------------------------------

M.Rest = {

    Studies  = "/studies",

    Series   = "/series",

    Instances = "/instances",

    Patients = "/patients"

}

------------------------------------------------------------------------------
-- Platform
------------------------------------------------------------------------------

M.Platform = {

    WindowsSeparator = "\\",

    UnixSeparator = "/"

}

------------------------------------------------------------------------------
-- Archive
------------------------------------------------------------------------------

M.Archive = {

    DefaultCompression = 5

}

------------------------------------------------------------------------------
-- Return Module
------------------------------------------------------------------------------

return M