%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/"],
        excluded: [~r"/_build/", ~r"/deps/"]
      },
      requires: [],
      check_for_updates: false,
      #
      # You can customize the parameters of any check by adding a second element
      # to the tuple.
      #
      # To disable a check put `false` as second element:
      #
      #     {Credo.Check.Design.DuplicatedCode, false}
      #
      checks: [
        {Credo.Check.Consistency.ExceptionNames},
        {Credo.Check.Consistency.LineEndings},
        {Credo.Check.Consistency.MultiAliasImportRequireUse},
        {Credo.Check.Consistency.SpaceAroundOperators},
        {Credo.Check.Consistency.SpaceInParentheses},
        {Credo.Check.Consistency.TabsOrSpaces},

        # For some checks, like AliasUsage, you can only customize the priority
        # Priority values are: `low, normal, high, higher` or disable it (false).
        {Credo.Check.Design.AliasUsage, false},

        # For others you can set parameters

        # If you don't want the `setup` and `test` macro calls in ExUnit tests
        # or the `schema` macro in Ecto schemas to trigger DuplicatedCode, just
        # set the `excluded_macros` parameter to `[:schema, :setup, :test]`.
        {Credo.Check.Design.DuplicatedCode, excluded_macros: []},

        # Disabled for now as they are also checked by Code Climate
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Design.TagFIXME, false},
        {Credo.Check.Readability.FunctionNames},
        {Credo.Check.Readability.MaxLineLength, false},
        {Credo.Check.Readability.ModuleAttributeNames},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Readability.ModuleNames},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs, false},
        {Credo.Check.Readability.ParenthesesInCondition},
        {Credo.Check.Readability.PredicateFunctionNames},
        {Credo.Check.Readability.TrailingBlankLine},
        {Credo.Check.Readability.TrailingWhiteSpace},
        {Credo.Check.Readability.VariableNames},
        {Credo.Check.Readability.RedundantBlankLines},
        {Credo.Check.Readability.SinglePipe, false},
        # This is the job of dialyzer
        {Credo.Check.Readability.Specs, false},
        {Credo.Check.Readability.StringSigils},
        {Credo.Check.Refactor.ABCSize, false},
        {Credo.Check.Refactor.CondStatements},
        # That's a feature!
        {Credo.Check.Refactor.DoubleBooleanNegation, false},
        {Credo.Check.Refactor.FunctionArity, max_arity: 8},
        {Credo.Check.Refactor.MatchInCondition},
        {Credo.Check.Refactor.PipeChainStart, false},
        {Credo.Check.Refactor.CyclomaticComplexity},
        {Credo.Check.Refactor.NegatedConditionsInUnless},
        {Credo.Check.Refactor.NegatedConditionsWithElse},
        {Credo.Check.Refactor.Nesting, max_nesting: 3},
        {Credo.Check.Refactor.UnlessWithElse},
        # That's a feature!
        {Credo.Check.Refactor.VariableRebinding, false},
        {Credo.Check.Warning.IExPry},
        {Credo.Check.Warning.IoInspect, false},

        # Those are warned by Elixir when it is ambiguous since Elixir v1.4
        {Credo.Check.Warning.OperationOnSameValues},
        {Credo.Check.Warning.BoolOperationOnSameValues},
        {Credo.Check.Warning.UnusedEnumOperation},
        {Credo.Check.Warning.UnusedKeywordOperation},
        {Credo.Check.Warning.UnusedListOperation},
        {Credo.Check.Warning.UnusedStringOperation},
        {Credo.Check.Warning.UnusedTupleOperation},
        {Credo.Check.Warning.OperationWithConstantResult}

        # Custom checks can be created using `mix credo.gen.check`.
        #
      ]
    }
  ]
}
