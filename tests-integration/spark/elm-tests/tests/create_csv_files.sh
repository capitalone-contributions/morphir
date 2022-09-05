#!/bin/bash

#   Copyright 2022 Morgan Stanley
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


#
# This script runs Elm tests with Antiques data in CSV format generated by GenerateAntiqueTestData.elm
#
# The output of the tests is written to CSV files which can be used as expected results in the
# corresponding Spark/Scala test for a particular rule in the Elm Antiques model.
#
set -ex

TEST_OUTPUT_DIR=$(mktemp -d -t elm-tests-XXXXXXXXXX)

SPARK_TEST_DATA_DIR=../../test/src/spark_test_data
mkdir -p "$SPARK_TEST_DATA_DIR"


# Generate the input test data as a CSV file of Antique records
elm-test GenerateAntiqueTestData.elm > "$TEST_OUTPUT_DIR/generate_antique_test_data.txt"
grep -m1 antiques_data.csv "$TEST_OUTPUT_DIR/generate_antique_test_data.txt" | sed -e 's?antiques_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/antiques_data.csv"

elm-test GenerateAntiqueSSTestData.elm > "$TEST_OUTPUT_DIR/generate_antiqueSS_test_data.txt"
grep -m1 antique_subset_data.csv "$TEST_OUTPUT_DIR/generate_antiqueSS_test_data.txt" | sed -e 's?antique_subset_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/antique_subset_data.csv"

elm-test GenerateProductData.elm > "$TEST_OUTPUT_DIR/generate_product_data.txt"
grep -m1 antique_product_data.csv "$TEST_OUTPUT_DIR/generate_product_data.txt" | sed -e 's?antique_product_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/antique_product_data.csv"

elm-test GenerateNameData.elm > "$TEST_OUTPUT_DIR/generate_name_data.txt"
grep -m1 antique_name_data.csv "$TEST_OUTPUT_DIR/generate_name_data.txt" | sed -e 's?antique_name_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/antique_name_data.csv"

elm-test GenerateAgeData.elm > "$TEST_OUTPUT_DIR/generate_age_data.txt"
grep -m1 antique_age_data.csv "$TEST_OUTPUT_DIR/generate_age_data.txt" | sed -e 's?antique_age_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/antique_age_data.csv"

elm-test GenerateFooBoolData.elm > "$TEST_OUTPUT_DIR/generate_foo_bool.txt"
grep -m1 foo_bool_data.csv "$TEST_OUTPUT_DIR/generate_foo_bool.txt" | sed -e 's?foo_bool_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/foo_bool_data.csv"

elm-test GenerateFooIntData.elm > "$TEST_OUTPUT_DIR/generate_foo_int.txt"
grep -m1 foo_int_data.csv "$TEST_OUTPUT_DIR/generate_foo_int.txt" | sed -e 's?foo_int_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/foo_int_data.csv"

elm-test GenerateFooFloatData.elm > "$TEST_OUTPUT_DIR/generate_foo_float.txt"
grep -m1 foo_float_data.csv "$TEST_OUTPUT_DIR/generate_foo_float.txt" | sed -e 's?foo_float_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/foo_float_data.csv"

elm-test GenerateFooStringData.elm > "$TEST_OUTPUT_DIR/generate_foo_string.txt"
grep -m1 foo_string_data.csv "$TEST_OUTPUT_DIR/generate_foo_string.txt" | sed -e 's?foo_string_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/foo_string_data.csv"

elm-test GenerateFooMaybeStringData.elm > "$TEST_OUTPUT_DIR/generate_foo_maybe_string.txt"
grep -m1 foo_maybe_string_data.csv "$TEST_OUTPUT_DIR/generate_foo_maybe_string.txt" | sed -e 's?foo_maybe_string_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/foo_maybe_string_data.csv"

elm-test GenerateFooMaybeIntData.elm > "$TEST_OUTPUT_DIR/generate_foo_maybe_int.txt"
grep -m1 foo_maybe_int_data.csv "$TEST_OUTPUT_DIR/generate_foo_maybe_int.txt" | sed -e 's?foo_maybe_int_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/foo_maybe_int_data.csv"

elm-test GenerateFooMaybeFloatData.elm > "$TEST_OUTPUT_DIR/generate_foo_maybe_float.txt"
grep -m1 foo_maybe_float_data.csv "$TEST_OUTPUT_DIR/generate_foo_maybe_float.txt" | sed -e 's?foo_maybe_float_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/foo_maybe_float_data.csv"

elm-test GenerateFooMaybeBoolData.elm > "$TEST_OUTPUT_DIR/generate_foo_maybe_bool.txt"
grep -m1 foo_maybe_bool_data.csv "$TEST_OUTPUT_DIR/generate_foo_maybe_bool.txt" | sed -e 's?foo_maybe_bool_data.csv: \["??' -e 's?",",?\n?g' -e 's?"]??' > "$SPARK_TEST_DATA_DIR/foo_maybe_bool_data.csv"

# Add Elm triple quotes around the CSV data
echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/antiques_data.csv" > "$TEST_OUTPUT_DIR/antiques_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/antiques_data.csv.in"

echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/antique_subset_data.csv" > "$TEST_OUTPUT_DIR/antique_subset_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/antique_subset_data.csv.in"

echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/antique_product_data.csv" > "$TEST_OUTPUT_DIR/antique_product_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/antique_product_data.csv.in"

echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/antique_name_data.csv" > "$TEST_OUTPUT_DIR/antique_name_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/antique_name_data.csv.in"

echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/antique_age_data.csv" > "$TEST_OUTPUT_DIR/antique_age_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/antique_age_data.csv.in"

echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/foo_float_data.csv" > "$TEST_OUTPUT_DIR/foo_float_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/foo_float_data.csv.in"

echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/foo_int_data.csv" > "$TEST_OUTPUT_DIR/foo_int_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/foo_int_data.csv.in"

echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/foo_bool_data.csv" > "$TEST_OUTPUT_DIR/foo_bool_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/foo_bool_data.csv.in"

echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/foo_string_data.csv" > "$TEST_OUTPUT_DIR/foo_string_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/foo_string_data.csv.in"

echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/foo_maybe_string_data.csv" > "$TEST_OUTPUT_DIR/foo_maybe_string_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/foo_maybe_string_data.csv.in"

echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/foo_maybe_int_data.csv" > "$TEST_OUTPUT_DIR/foo_maybe_int_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/foo_maybe_int_data.csv.in"

echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/foo_maybe_bool_data.csv" > "$TEST_OUTPUT_DIR/foo_maybe_bool_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/foo_maybe_bool_data.csv.in"

echo -n '    """' | cat - "$SPARK_TEST_DATA_DIR/foo_maybe_float_data.csv" > "$TEST_OUTPUT_DIR/foo_maybe_float_data.csv.in"
echo '"""' >> "$TEST_OUTPUT_DIR/foo_maybe_float_data.csv.in"

# Update src/AntiquesDataSource.elm source with the newly generated Antiques CSV data
cat ../src/AntiquesDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^csvData =/ r $TEST_OUTPUT_DIR/antiques_data.csv.in" > "$TEST_OUTPUT_DIR/Temp.elm"
cp "$TEST_OUTPUT_DIR/Temp.elm" ../src/AntiquesDataSource.elm

cat ../src/AntiqueSSDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^csvSSData =/ r $TEST_OUTPUT_DIR/antique_subset_data.csv.in" > "$TEST_OUTPUT_DIR/Temp2.elm"
cp "$TEST_OUTPUT_DIR/Temp2.elm" ../src/AntiqueSSDataSource.elm

cat ../src/AntiqueProductDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^csvProductData =/ r $TEST_OUTPUT_DIR/antique_product_data.csv.in" > "$TEST_OUTPUT_DIR/Temp3.elm"
cp "$TEST_OUTPUT_DIR/Temp3.elm" ../src/AntiqueProductDataSource.elm

cat ../src/AntiqueNameDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^csvNameData =/ r $TEST_OUTPUT_DIR/antique_name_data.csv.in" > "$TEST_OUTPUT_DIR/Temp4.elm"
cp "$TEST_OUTPUT_DIR/Temp4.elm" ../src/AntiqueNameDataSource.elm

cat ../src/AntiqueAgeDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^csvAgeData =/ r $TEST_OUTPUT_DIR/antique_age_data.csv.in" > "$TEST_OUTPUT_DIR/Temp5.elm"
cp "$TEST_OUTPUT_DIR/Temp5.elm" ../src/AntiqueAgeDataSource.elm

cat ../src/FooIntDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^fooIntData =/ r $TEST_OUTPUT_DIR/foo_int_data.csv.in" > "$TEST_OUTPUT_DIR/Temp6.elm"
cp "$TEST_OUTPUT_DIR/Temp6.elm" ../src/FooIntDataSource.elm

cat ../src/FooFloatDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^fooFloatData =/ r $TEST_OUTPUT_DIR/foo_float_data.csv.in" > "$TEST_OUTPUT_DIR/Temp7.elm"
cp "$TEST_OUTPUT_DIR/Temp7.elm" ../src/FooFloatDataSource.elm

cat ../src/FooStringDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^fooStringData =/ r $TEST_OUTPUT_DIR/foo_string_data.csv.in" > "$TEST_OUTPUT_DIR/Temp8.elm"
cp "$TEST_OUTPUT_DIR/Temp8.elm" ../src/FooStringDataSource.elm

cat ../src/FooBoolDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^fooBoolData =/ r $TEST_OUTPUT_DIR/foo_bool_data.csv.in" > "$TEST_OUTPUT_DIR/Temp9.elm"
cp "$TEST_OUTPUT_DIR/Temp9.elm" ../src/FooBoolDataSource.elm

cat ../src/FooMaybeIntDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^fooMaybeIntData =/ r $TEST_OUTPUT_DIR/foo_maybe_int_data.csv.in" > "$TEST_OUTPUT_DIR/Temp10.elm"
cp "$TEST_OUTPUT_DIR/Temp10.elm" ../src/FooMaybeIntDataSource.elm

cat ../src/FooMaybeFloatDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^fooMaybeFloatData =/ r $TEST_OUTPUT_DIR/foo_maybe_float_data.csv.in" > "$TEST_OUTPUT_DIR/Temp11.elm"
cp "$TEST_OUTPUT_DIR/Temp11.elm" ../src/FooMaybeFloatDataSource.elm

cat ../src/FooMaybeStringDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^fooMaybeStringData =/ r $TEST_OUTPUT_DIR/foo_maybe_string_data.csv.in" > "$TEST_OUTPUT_DIR/Temp12.elm"
cp "$TEST_OUTPUT_DIR/Temp12.elm" ../src/FooMaybeStringDataSource.elm

cat ../src/FooMaybeBoolDataSource.elm \
    | sed -e '/^    """/,/^"""/d' \
    | sed -e "/^fooMaybeBoolData =/ r $TEST_OUTPUT_DIR/foo_maybe_bool_data.csv.in" > "$TEST_OUTPUT_DIR/Temp13.elm"
cp "$TEST_OUTPUT_DIR/Temp13.elm" ../src/FooMaybeBoolDataSource.elm

elmTestOutputToCsv () {
    elm-test "$1" > "$TEST_OUTPUT_DIR/$2.txt"
    grep -m1 "expected_results_$2.csv" "$TEST_OUTPUT_DIR/$2.txt" |sed -e "s?expected_results_$2.csv: Ok \"??" -e 's?"??g' -e 's?\\r\\n?\n?g' \
    > "$SPARK_TEST_DATA_DIR/expected_results_$2.csv"
}


# Run the is_item_vintage test and save the corresponding CSV file
elmTestOutputToCsv "TestIsItemVintage.elm" "is_item_vintage"

# Run the is_item_worth_millions test and save the corresponding CSV file
elmTestOutputToCsv "TestIsItemWorthMillions.elm" "is_item_worth_millions"

# Run the is_item_worth_thousands test and save the corresponding CSV file
elmTestOutputToCsv "TestIsItemWorthThousands.elm" "is_item_worth_thousands"

# Run the is_item_antique test and save the corresponding CSV file
elmTestOutputToCsv "TestIsItemAntique.elm" "is_item_antique"

# Run the seize_item test and save the corresponding CSV file
elmTestOutputToCsv "TestSeizeItem.elm" "seize_item"


# Run the christmas_bonanza_15percent_priceRange test and save the corresponding CSV file
# This one is slightly different from the others because it manually reformats the output into csv
elm-test "TestChristmasBonanza.elm" > "$TEST_OUTPUT_DIR/christmas_bonanza_15percent_priceRange.txt"
grep -m1 "expected_results_christmas_bonanza_15percent_priceRange.csv" "$TEST_OUTPUT_DIR/christmas_bonanza_15percent_priceRange.txt" | sed -e "s?expected_results_christmas_bonanza_15percent_priceRange.csv: Ok (??" -e 's?)??g' -e 'i minimum,maximum' \
> "$SPARK_TEST_DATA_DIR/expected_results_christmas_bonanza_15percent_priceRange.csv"


elmTestOutputToCsv "TestAntiqueSSCaseString.elm" "testCaseString"

elmTestOutputToCsv "TestAntiqueSSCaseEnum.elm" "testCaseEnum"

elmTestOutputToCsv "TestAntiqueSSFrom.elm" "testFrom"

elmTestOutputToCsv "TestAntiqueSSWhere1.elm" "testWhere1"

elmTestOutputToCsv "TestAntiqueSSWhere2.elm" "testWhere2"

elmTestOutputToCsv "TestAntiqueSSWhere3.elm" "testWhere3"

elmTestOutputToCsv "TestAntiqueSSSelect1.elm" "testSelect1" 

elmTestOutputToCsv "TestAntiqueSSSelect3.elm" "testSelect3"

elmTestOutputToCsv "TestAntiqueSSSelect4.elm" "testSelect4"

###########################elmTestOutputToCsv "TestAntiqueSSFilter.elm" "testFilter"  ##FILTERFN DIVIDE BY ZERO ERROR

elmTestOutputToCsv "TestAntiqueSSFilter2.elm" "testFilter2"

###########################elmTestOutputToCsv "TestAntiqueSSMapAndFilter.elm" "testMapAndFilter" ##FILTERFN DIVIDE BY ZERO ERROR

###########################elmTestOutputToCsv "TestAntiqueSSMapAndFilter2.elm" "testMapAndFilter2" ##FILTERFN DIVIDE BY ZERO ERROR

###########################elmTestOutputToCsv "TestAntiqueSSMapAndFilter3.elm" "testMapAndFilter3" ##FILTERFN DIVIDE BY ZERO ERROR

elmTestOutputToCsv "TestAntiqueSSListMaximum.elm" "testListMaximum"

elmTestOutputToCsv "TestAntiqueSSListMinimum.elm" "testListMinimum"

elmTestOutputToCsv "TestAntiqueSSNameMaximum.elm" "testNameMaximum" 

elmTestOutputToCsv "TestAntiqueSSBadAnnotation.elm" "testBadAnnotation"

elmTestOutputToCsv "TestAntiqueSSLetBinding.elm" "testLetBinding"

elmTestOutputToCsv "TestAntiqueSSListSum.elm" "testListSum"

elmTestOutputToCsv "TestAntiqueSSListLength.elm" "testListLength"

elmTestOutputToCsv "TestEnumListMember.elm" "testEnumListMember"

elmTestOutputToCsv "TestStringListMember.elm" "testStringListMember"

elmTestOutputToCsv "TestIntListMember.elm" "testIntListMember"

elmTestOutputToCsv "TestEnum.elm" "testEnum"

elmTestOutputToCsv "TestCaseInt.elm" "testCaseInt"

elmTestOutputToCsv "TestCaseBool.elm" "testCaseBool"

elmTestOutputToCsv "TestString.elm" "testString"

elmTestOutputToCsv "TestFloat.elm" "testFloat"

elmTestOutputToCsv "TestInt.elm" "testInt"

elmTestOutputToCsv "TestBool.elm" "testBool"

elmTestOutputToCsv "TestMaybeString.elm" "testMaybeString"

elmTestOutputToCsv "TestMaybeFloat.elm" "testMaybeFloat"

elmTestOutputToCsv "TestMaybeInt.elm" "testMaybeInt"

elmTestOutputToCsv "TestMaybeBoolConditional.elm" "testMaybeBoolConditional"

elmTestOutputToCsv "TestMaybeBoolConditionalNull.elm" "testMaybeBoolConditionalNull"

elmTestOutputToCsv "TestMaybeBoolConditionalNotNull.elm" "testMaybeBoolConditionalNotNull"

elmTestOutputToCsv "TestMaybeMapDefault.elm" "testMaybeMapDefault"



