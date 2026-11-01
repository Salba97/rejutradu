class Typemod
  attr_reader :numerator
  attr_reader :denominator

  def initialize(numerator = 1, denominator = 1)
    @numerator = numerator
    @denominator = denominator
  end

  def *(obj)
    numerator = self.numerator * obj.numerator
    denominator = self.denominator * obj.denominator
    denominator = 1 if numerator == 0
    if numerator > 1 && denominator > 1
      modifier = [numerator, denominator].min
      numerator /= modifier
      denominator /= modifier
    end
    return Typemod.new(numerator, denominator)
  end

  def negative?
    return @numerator < 0
  end

  def immune?
    return @numerator <= 0
  end

  def doubleResisted?
    return @denominator >= 4
  end

  def resisted?
    return @denominator >= 2
  end

  def neutral?
    return @numerator == 1 && @denominator == 1
  end

  def effective?
    return @numerator >= 1 && @denominator == 1
  end

  def superEffective?
    return @numerator >= 2
  end

  def doubleSuperEffective?
    return @numerator >= 4
  end

  def resistedOrImmune?
    return resisted? || immune?
  end

  def doubleResistedOrImmune?
    return doubleResisted? || immune?
  end

  def inverse
    return Typemod.double if @numerator == 0
    return Typemod.new(@denominator, @numerator)
  end

  def multiplier
    return (@numerator == -1 ? 0 : @numerator) * 1.0 / @denominator
  end

  def self.negative
    return Typemod.new(-1)
  end

  def self.zero
    return Typemod.new(0)
  end

  def self.normal
    return Typemod.new
  end

  def self.half
    return Typemod.new(1, 2)
  end

  def self.double
    return Typemod.new(2)
  end

  def self.max(typemod, *typemods)
    typemods.each do |mod|
      typemod = mod if mod.multiplier > typemod.multiplier
    end
    return typemod
  end
end
