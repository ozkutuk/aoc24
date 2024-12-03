% vim: set ft=prolog :

:- use_module(library(clpz)).
:- use_module(library(reif)).
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(pio)).
:- use_module(library(charsio)).
:- use_module(library(os)).

:- initialization(run).

% The input is a newline-seperated list of reports
reports([L|Ls]) --> report(L), "\n", reports(Ls).
reports([]) --> [].

% A report is a space-separated list of integers
report([N|Ns]) --> integer(N), report_r(Ns).

report_r([N|Ns]) --> " ", report([N|Ns]).
report_r([]) --> [].

% An integer is a sequence of digits
integer(I) --> digits(Ds), { number_chars(I, Ds) }.

digits([D|Ds]) --> digit(D), digits_r(Ds).

digits_r([D|Ds]) --> digit(D), digits_r(Ds).
digits_r([]) --> [].

digit(D) --> [D], { char_type(D, decimal_digit) }.

all_ascending([]).
all_ascending([_]).
all_ascending([N0,N1|Ns]) :-
    N1 #> N0,
    all_ascending([N1|Ns]).

all_descending([]).
all_descending([_]).
all_descending([N0,N1|Ns]) :-
    N1 #< N0,
    all_descending([N1|Ns]).

all_ascending_or_descending(Ns) :- all_ascending(Ns).
all_ascending_or_descending(Ns) :- all_descending(Ns).

satisfies_diff_bound([]).
satisfies_diff_bound([_]).
satisfies_diff_bound([N0,N1|Ns]) :-
    Diff #= abs(N0 - N1),
    Diff #>= 1,
    Diff #=< 3,
    satisfies_diff_bound([N1|Ns]).

valid_report(Report) :-
    all_ascending_or_descending(Report),
    satisfies_diff_bound(Report).

lax_valid_report(Report) :- valid_report(Report).
lax_valid_report(Report) :-
    append(BeforeRemoval, [_|AfterRemoval], Report),
    append(BeforeRemoval, AfterRemoval, LaxReport),
    valid_report(LaxReport).

reports_valid(_, [], []).
reports_valid(Validator_1, [R|Rs], Vs) :-
    call(Validator_1, R),
    Vs = [R|Vs1],
    reports_valid(Validator_1, Rs, Vs1).
reports_valid(Validator_1, [_|Rs], Vs) :-
    reports_valid(Validator_1, Rs, Vs).

part1(Reports, Count) :-
    reports_valid(valid_report, Reports, Valids),
    length(Valids, Count).

part2(Reports, Count) :-
    reports_valid(lax_valid_report, Reports, Valids),
    length(Valids, Count).

solve(InFile, Part1, Part2) :-
    phrase_from_file(reports(Reports), InFile),
    part1(Reports, Part1),
    part2(Reports, Part2).

% Run with:
% scryer-prolog day2.pl -- input.txt
run :-
    argv([InFile|_]),
    solve(InFile, Part1, Part2),
    write(Part1),
    nl,
    write(Part2),
    nl,
    halt.
