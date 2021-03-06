require "test_helper"

class IntegerSchemaTest < Test::Unit::TestCase
  def test_expected_value_are_not_converted
    s = Respect::IntegerSchema.new(equal_to: "42")
    assert_raise(Respect::ValidationError) do
      s.validate(42)
    end
  end

  def test_malformed_string_value_raise_exception
    s = Respect::IntegerSchema.new
    [
      "s42",
      "4s2",
      "42s",
      "4-2",
      "42-",
      "-+42",
      "+-42",
      "42.5",
      "0.5",
    ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate_type(test_value)
      end
    end
  end

  def test_string_value_get_converted
    [
      [ "-42", -42 ],
      [ "+42",  42 ],
      [  "42",  42 ],
    ].each do |test_data|
      s = Respect::IntegerSchema.new
      assert_equal test_data[1], s.validate_type(test_data[0])
      assert_nil s.sanitized_object
      s.validate(test_data[0])
      assert_equal test_data[1], s.sanitized_object
    end
  end

  def test_integer_accept_equal_to_constraint
    s = Respect::IntegerSchema.new(equal_to: 41)
    assert_schema_validate s, 41
    assert_schema_invalidate s, 52
  end

  def test_greater_than_constraint_works
    s = Respect::IntegerSchema.new(greater_than: 0)
    assert s.validate(42)
    [ 0, -42 ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate(test_value)
      end
    end
  end

  def test_greater_than_or_equal_to_constraint_works
    s = Respect::IntegerSchema.new(greater_than_or_equal_to: 0)
    assert s.validate(42)
    assert s.validate(0)
    assert_raise(Respect::ValidationError) do
      s.validate(-42)
    end
  end

  def test_less_than_constraint_works
    s = Respect::IntegerSchema.new(less_than: 0)
    assert s.validate(-1)
    [ 0, 1 ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate(test_value)
      end
    end
  end

  def test_less_than_or_equal_to_constraint_works
    s = Respect::IntegerSchema.new(less_than_or_equal_to: 0)
    assert s.validate(-1)
    assert s.validate(0)
    assert_raise(Respect::ValidationError) do
      s.validate(1)
    end
  end

  def test_integer_value_is_in_set
    s = Respect::IntegerSchema.new(in: [42, 51])
    assert_schema_validate s, 42
    assert_schema_validate s, 51
    assert_schema_invalidate s, 1664
  end

  def test_integer_value_is_in_range
    s = Respect::IntegerSchema.new(in: 1..4)
    assert_schema_invalidate s, 0
    assert_schema_validate s, 1
    assert_schema_validate s, 2
    assert_schema_validate s, 3
    assert_schema_validate s, 4
    assert_schema_invalidate s, 5

    s = Respect::IntegerSchema.new(in: 1...4)
    assert_schema_invalidate s, 0
    assert_schema_validate s, 1
    assert_schema_validate s, 2
    assert_schema_validate s, 3
    assert_schema_invalidate s, 4
    assert_schema_invalidate s, 5
  end

  def test_failed_validation_reset_sanitized_object
    s = Respect::IntegerSchema.define equal_to: 42
    assert_schema_validate(s, 42)
    assert_equal(42, s.sanitized_object)
    assert_schema_invalidate(s, 51)
    assert_equal(nil, s.sanitized_object)
  end

  def test_allow_nil
    s = Respect::IntegerSchema.new(allow_nil: true)
    assert_schema_validate s, nil
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, 42
    assert_equal(42, s.sanitized_object)
    assert_schema_validate s, "42"
    assert_equal(42, s.sanitized_object)
  end

  def test_disallow_nil
    s = Respect::IntegerSchema.new
    assert !s.allow_nil?
    exception = assert_exception(Respect::ValidationError) { s.validate(nil) }
    assert_match /\bIntegerSchema\b/, exception.message
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, 42
    assert_equal(42, s.sanitized_object)
    assert_schema_validate s, "42"
    assert_equal(42, s.sanitized_object)
  end
end
