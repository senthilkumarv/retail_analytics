class Substitution
    def initialize(looked_up_variant, substitute_variant, probability)
        @looked_up_variant = looked_up_variant
        @substitute_variant = substitute_variant
        @probability = probability
    end

    attr_accessor :looked_up_variant, :substitute_variant, :probability
end
