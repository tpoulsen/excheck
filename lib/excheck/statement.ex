defmodule ExCheck.Statement do
  @moduledoc """
  Provides macros for test statements.
  """

  #@doc """
  #Generate property method and ExUnit tests.
  #"""
  #defmacro property(message, [do: contents]) do
  #  contents = Macro.escape(contents, unquote: true)
  #  quote bind_quoted: binding do
  #    name = ExUnit.Case.register_test(__ENV__, :property, message, [])
  #    def unquote(name)(), do: unquote(contents)
  #    test :"#{message}_property", context do
  #      assert ExCheck.check(unquote(:"prop_#{message}")(), context[:iterations])
  #    end
  #  end
  #end

  @doc """
  Generate property method and ExUnit tests with var context.
  """
  defmacro property(message, var \\ quote(do: _), [do: contents]) do
    var      = Macro.escape(var)
    contents = Macro.escape(contents, unquote: true)
    quote bind_quoted: binding do
      name = ExUnit.Case.register_test(__ENV__, :property, message, [])
      def unquote(name)(unquote(var)), do: unquote(contents)
      test :"#{message}_property", var do
        assert ExCheck.check(unquote(name)(var), var[:iterations])
      end
    end
  end

  @doc """
  Verify property and return the result as true/faluse value.
  It corresonds to triq#check_forall method.
  """
  def verify_property({:"prop:forall", domain, _syntax, fun, _body}) do
    iterations = Application.get_env(:excheck, :number_iterations, 100)
    verify_property(0, iterations, domain, fun, 0)
  end

  defp verify_property(n, n, _domain, _fun, _count), do: true
  defp verify_property(n, nmax, domain, fun, count) do
    domain_size = 2 * 2 + n
    {_, sample} = :triq_dom.pick(domain, domain_size)

    if fun.(sample) do
      verify_property(n + 1, nmax, domain, fun, count + 1)
    else
      false
    end
  end
end
