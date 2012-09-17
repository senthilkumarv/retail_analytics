require "./substitution"

class SubstitutionGenerator
    def initialize(repository, all_variants)
        @repository = repository
        @all_variants = all_variants

        @total_variants_count = @repository.total_number_of_variants
        @total_purchase_count = @repository.number_of_variants_purchased
        @total_lookup_count = @repository.number_of_variants_looked_at
    end

    def generate(looked_up_variant)
        substitutions = []
        @all_variants.each do |variant|
            next unless variant != looked_up_variant
            probability = compute_buying_probability(looked_up_variant, variant)
            substitutions << Substitution.new(looked_up_variant, variant, probability) if probability != -1
        end
        substitutions
    end

    def compute_buying_probability(searched_variant, substitute_variant)
        purchase_count_of_substitute_variant = @repository.purchase_count(substitute_variant)
        lookup_count_of_searched_variant = @repository.lookup_count(searched_variant)
        return -1 if (purchase_count_of_substitute_variant == 0 || lookup_count_of_searched_variant == 0)
        substitution_count = @repository.substitution_count(searched_variant, substitute_variant)


        prior_probability = (substitution_count + 1).to_f / (purchase_count_of_substitute_variant + @total_variants_count) # Laplace Smoothing. Probability of
                                                                                                                     # searched variant being looked up
                                                                                                                     # given the substituted variant was bought
        purchase_probability_of_substitute_variant = purchase_count_of_substitute_variant.to_f / @total_purchase_count
        lookup_probability_of_searched_variant = lookup_count_of_searched_variant.to_f / @total_lookup_count

        (prior_probability * purchase_probability_of_substitute_variant).to_f / lookup_count_of_searched_variant
    end
end
