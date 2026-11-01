class PBTypes
  def PBTypes.getCount
    return $cache.types.length
  end

  def PBTypes.isSpecialType?(type)
    return $cache.types[type].specialtype?(type)
  end

  def PBTypes.oneTypeEff(attackType, opponentType, inverse: false)
    return Typemod.normal if opponentType.nil?
    typemod = Typemod.normal
    typemod = Typemod.double if $cache.types[opponentType].weak?(attackType)
    typemod = Typemod.half if $cache.types[opponentType].resists?(attackType)
    typemod = Typemod.zero if $cache.types[opponentType].immune?(attackType)
    typemod = typemod.inverse if inverse
    return typemod
  end

  def PBTypes.typesEff(attackType, types, inverse: false)
    typemod = Typemod.normal
    for type in types.uniq
      typemod *= oneTypeEff(attackType, type, inverse: inverse)
    end
    return typemod
  end

  def PBTypes.typeResists(type)
    resists = []
    for i in $cache.types.keys
      resists.push(i) if $cache.types[i].resists?(type) || $cache.types[i].immune?(type)
    end
    return resists
  end
end
