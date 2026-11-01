class Object
  def deep_clone(namespace = {})
    return deep_clone_internal(namespace, &:deep_clone)
  end

  def pbCopyToBattleState(namespace = {})
    return deep_clone_internal(namespace, &:pbCopyToBattleState)
  end

  protected
  def deep_clone_internal(namespace = {}, &copyMethod)
    return namespace[object_id] if namespace.include?(object_id)

    copied = clone
    namespace[object_id] = copied

    instance_variables.each do |ivar_name|
      ivar_value = instance_variable_get ivar_name
      copied.instance_variable_set(ivar_name, copyMethod.call(ivar_value, namespace))
    end
    return copied
  end
end

module SnapshotByVariables
  def deep_clone(namespace = {})
    return deep_clone_internal(false, namespace, &:deep_clone)
  end

  def pbCopyToBattleState(namespace = {})
    return deep_clone_internal(true, namespace, &:pbCopyToBattleState)
  end

  protected
  def deep_clone_internal(removeBlacklistedVars, namespace = {}, &copyMethod)
    return namespace[object_id] if namespace.include?(object_id)

    copied = clone
    namespace[object_id] = copied

    instance_variables.each do |ivar_name|
      if self.class::SNAPSHOT_VARIABLE_BLACKLIST.include?(ivar_name)
        copied.remove_instance_variable(ivar_name) if removeBlacklistedVars
        next
      end
      ivar_value = instance_variable_get ivar_name
      copied.instance_variable_set(ivar_name, copyMethod.call(ivar_value, namespace))
    end
    return copied
  end
end

class Array
  protected
  def deep_clone_internal(namespace = {}, &copyMethod)
    return namespace[object_id] if namespace.include?(object_id)

    copied = []
    namespace[object_id] = copied

    each do |value|
      copied.push(copyMethod.call(value, namespace))
    end
    return copied
  end
end

class Hash
  protected
  def deep_clone_internal(namespace = {}, &copyMethod)
    return namespace[object_id] if namespace.include?(object_id)

    copied = {}
    copied.default = default
    namespace[object_id] = copied

    each do |key, value|
      copied[copyMethod.call(key, namespace)] = copyMethod.call(value, namespace)
    end

    return copied
  end
end

class PokeBattle_Field
  include SnapshotByVariables
  # fieldroll and overlayroll are blacklisted as both should under no circumstances be set outside of move execution
  SNAPSHOT_VARIABLE_BLACKLIST = [:@fieldroll, :@overlayroll]
end

class PokeBattle_Move
  include SnapshotByVariables
  # immediate is blacklisted as immediate should under no circumstances be set outside of move execution
  SNAPSHOT_VARIABLE_BLACKLIST = [:@immediate]
end

class PokeBattle_Battle
  include SnapshotByVariables
  # scene and battlescene are 90% of the reason why battle isn't serializable, we also do not need to copy them, for any use case
  # as we don't intend to jump into the middle of a turn, copying the phase tracker would cause more harm than good
  # snapshot stores battle state backups like this, it's generally not advised to overwrite with a battle state backup
  # there is frankly no reason to copy the struggle move instance, it is the same in every single battle
  # moveOrder and speedOrder would cause issues if copied, just rerun setMoveOrder and setSpeedOrder after loading a savestate
  # turn_data is effectively the choice list for the test enviroment, don't overwrite it with a savesate it will break tests using this
  SNAPSHOT_VARIABLE_BLACKLIST = [:@scene, :@battlescene, :@phase, :@snapshot, :@struggle, :@moveOrder, :@speedOrder, :@turn_data, :@fakeopponent]
end
