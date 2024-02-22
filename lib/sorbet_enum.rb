# typed: true
# frozen_string_literal: true

require 'active_record'
require 'sorbet-runtime'

module SorbetEnum
  extend T::Helpers
  interface!

  module ClassMethods
    extend T::Sig
    extend T::Helpers
    abstract!

    include ActiveRecord::Enum

    sig { params(name: Symbol, type: T.class_of(T::Enum)).void }
    def sorbet_enum(name, type)
      sorbet_enum_attributes << [name, type]

      attr_accessor(name)

      enum(name, type.values.map(&:serialize).index_with(&:to_s))

      T.unsafe(self).define_method("#{name}_enum") do
        type.deserialize(T.unsafe(self).public_send(name))
      end

      T.unsafe(self).define_method("#{name}_enum=") do |value|
        send("#{name}=", value.serialize)
      end
    end

    def sorbet_enum_attributes
      @sorbet_enum_attributes ||= []
    end
  end

  mixes_in_class_methods(ClassMethods)
end
