%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(apxr_pb_names).
-define(apxr_pb_names, true).

-define(apxr_pb_names_gpb_version, "4.5.1").

-ifndef('NAMES_PB_H').
-define('NAMES_PB_H', true).
-record('Names',
        {projects = []          :: [apxr_pb_names:'Project'()] | undefined, % = 1
         repository             :: iolist()         % = 2
        }).
-endif.

-ifndef('PROJECT_PB_H').
-define('PROJECT_PB_H', true).
-record('Project',
        {name                   :: iolist()         % = 1
        }).
-endif.

-endif.
