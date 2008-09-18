require "helper"

class TestEvolution < Test::Unit::TestCase
  def test_evolution
    mod = Bootstrapper.evolve(OMeta::GRAMMAR_FILES, 3)

    assert_not_nil(mod.source)
    assert_not_nil(mod.previous)
    assert_equal(mod.previous.source, mod.source)
  end
end
