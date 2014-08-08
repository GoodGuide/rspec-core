Feature: Explicit Subject

  Use `subject` in the group scope to explicitly define the value that is returned by the
  `subject` method in the example scope.

  Note that while the examples below demonstrate how the `subject` helper can be used
  as a user-facing concept, we recommend that you reserve it for support of custom
  matchers and/or extension libraries that hide its use from examples.

  A named `subject` improves on the explicit `subject` by assigning it a contextually
  semantic name. Since a named `subject` is an explicit `subject`, it still defines the value
  that is returned by the `subject` method in the example scope. However, it defines an
  additional helper method with the provided name. This helper method is memoized.
  The value is cached across multiple calls in the same example but not across examples.

  We recommend using the named helper method over `subject` in examples.

  For more information about declaring a `subject` see the [API docs](http://rubydoc.info/github/rspec/rspec-core/RSpec/Core/MemoizedHelpers/ClassMethods#subject-instance_method).

  Scenario: A `subject` can be defined and used in the top level group scope
    Given a file named "top_level_subject_spec.rb" with:
      """ruby
      RSpec.describe Array, "with some elements" do
        subject do
          [1, 2, 3]
        end

        it "has the prescribed elements" do
          expect(subject).to eq([1, 2, 3])
        end
      end
      """
    When I run `rspec top_level_subject_spec.rb`
    Then the examples should all pass

  Scenario: The `subject` defined in an outer group is available to inner groups
    Given a file named "nested_subject_spec.rb" with:
      """ruby
      RSpec.describe Array do
        subject do
          [1, 2, 3]
        end

        describe "has some elements" do
          it "which are the prescribed elements" do
            expect(subject).to eq([1, 2, 3])
          end
        end
      end
      """
    When I run `rspec nested_subject_spec.rb`
    Then the examples should all pass

  Scenario: The `subject` is available in `before` hooks
    Given a file named "top_level_subject_spec.rb" with:
      """ruby
      RSpec.describe Array, "with some elements" do
        subject do
          []
        end

        before do
          subject.push(1, 2, 3)
        end

        it "has the prescribed elements" do
          expect(subject).to eq([1, 2, 3])
        end
      end
      """
    When I run `rspec top_level_subject_spec.rb`
    Then the examples should all pass

  Scenario: Helper methods can be invoked from a `subject` definition block
    Given a file named "helper_subject_spec.rb" with:
      """ruby
      RSpec.describe Array do
        def prepared_array
          [1, 2, 3]
        end

        context "with some elements" do
          subject do
            prepared_array
          end

          it "has the prescribed elements" do
            expect(subject).to eq([1, 2, 3])
          end
        end
      end
      """
    When I run `rspec helper_subject_spec.rb`
    Then the examples should all pass

  Scenario: A `subject` definition block is invoked at most once per example
    Given a file named "nil_subject_spec.rb" with:
      """ruby
      RSpec.describe Array do
        def increment_counter
          @counter ||= 0
          @counter += 1
        end

        subject do
          increment_counter
          [1, 2, 3]
        end

        before do
          subject.push(4, 5)
        end

        it "has all prescribed elements" do
          expect(subject).to eq([1, 2, 3, 4, 5])
          subject.clear
          expect(subject).to be_empty
          expect(@counter).to eq 1
        end
      end
      """
    When I run `rspec nil_subject_spec.rb`
    Then the examples should all pass

  Scenario: Use the `subject!` bang method to call the definition block before the example
    Given a file named "subject_bang_spec.rb" with:
      """ruby
      RSpec.describe "eager loading with subject!" do
        subject! do
          invocation_order << :subject!
          [1, 1, 2, 3, 5]
        end

        let(:invocation_order) do
          []
        end

        it "calls the definition block before the example" do
          invocation_order << :example
          expect(invocation_order).to eq([:subject!, :example])
          expect(subject).to eq([1, 1, 2, 3, 5])
        end
      end
      """
    When I run `rspec subject_bang_spec.rb`
    Then the examples should all pass

  Scenario: Use `subject(:name)` to define a memoized helper method
    **Note:** that while a global variable is used in the examples below, this
    behavior is strongly discouraged in actual specs. It is used here simply to
    demonstrate the value will be cached across multiple calls in the same
    example but not across examples.
    Given a file named "named_subject_spec.rb" with:
      """ruby
      $count = 0

      RSpec.describe "named subject" do
        subject(:global_count) do
          $count += 1
        end

        it "memoizes the value" do
          expect(global_count).to eq(1)
          expect(global_count).to eq(1)
          expect(subject).to eq(1)
          is_expected.to eq(1)
        end

        it "is not cached across examples" do
          expect(global_count).to eq(2)
          expect(subject).to eq(2)
          is_expected.to eq(2)
        end

        it "is still available using the subject method" do
          expect(subject).to eq(3)
        end

        it "works with the one-liner syntax" do
          is_expected.to eq(4)
        end
      end
      """
    When I run `rspec named_subject_spec.rb`
    Then the examples should all pass

  Scenario: Use `subject!(:name)` to define a helper method called before the example
    Given a file named "named_subject_bang_spec.rb" with:
      """ruby
      RSpec.describe "eager loading using a named subject!" do
        subject!(:finite_fibonacci_sequence) do
          invocation_order << :subject!
          [1, 1, 2, 3, 5]
        end

        let(:invocation_order) do
          []
        end

        it "calls the helper method in a before hook" do
          invocation_order << :example
          expect(invocation_order).to eq([:subject!, :example])
          expect(finite_fibonacci_sequence).to eq([1, 1, 2, 3, 5])
        end
      end
      """
    When I run `rspec named_subject_bang_spec.rb`
    Then the examples should all pass
