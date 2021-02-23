{-
   Copyright 2020 Morgan Stanley

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-}


module Morphir.IR exposing
    ( IR
    , fromDistribution
    , lookupTypeSpecification, lookupTypeConstructor, lookupValueSpecification
    )

{-| This module contains data structures and functions to make working with the IR easier and more efficient.

@docs IR


# Conversions

@docs fromDistribution


# Lookups

@docs lookupTypeSpecification, lookupTypeConstructor, lookupValueSpecification

-}

import Dict exposing (Dict)
import Morphir.IR.Distribution as Distribution exposing (Distribution)
import Morphir.IR.FQName exposing (FQName)
import Morphir.IR.Name exposing (Name)
import Morphir.IR.Package as Package exposing (PackageName)
import Morphir.IR.Type as Type exposing (Type)
import Morphir.IR.Value as Value


{-| Data structure to store types and values efficiently.
-}
type alias IR =
    { valueSpecifications : Dict FQName (Value.Specification ())
    , typeSpecifications : Dict FQName (Type.Specification ())
    , typeConstructors : Dict FQName ( FQName, List Name, List ( Name, Type () ) )
    }


{-| Turn a `Distribution` into an `IR`. The `Distribution` data type is optimized for transfer while the `IR` data type
is optimized for efficient in-memory processing.
-}
fromDistribution : Distribution -> IR
fromDistribution (Distribution.Library libraryName dependencies packageDef) =
    let
        packageValueSpecifications : PackageName -> Package.Specification () -> List ( FQName, Value.Specification () )
        packageValueSpecifications packageName packageSpec =
            packageSpec.modules
                |> Dict.toList
                |> List.concatMap
                    (\( moduleName, moduleSpec ) ->
                        moduleSpec.values
                            |> Dict.toList
                            |> List.map
                                (\( valueName, valueSpec ) ->
                                    ( ( packageName, moduleName, valueName ), valueSpec )
                                )
                    )

        packageTypeSpecifications : PackageName -> Package.Specification () -> List ( FQName, Type.Specification () )
        packageTypeSpecifications packageName packageSpec =
            packageSpec.modules
                |> Dict.toList
                |> List.concatMap
                    (\( moduleName, moduleSpec ) ->
                        moduleSpec.types
                            |> Dict.toList
                            |> List.map
                                (\( typeName, typeSpec ) ->
                                    ( ( packageName, moduleName, typeName ), typeSpec.value )
                                )
                    )

        packageTypeConstructors : PackageName -> Package.Specification () -> List ( FQName, ( FQName, List Name, List ( Name, Type () ) ) )
        packageTypeConstructors packageName packageSpec =
            packageSpec.modules
                |> Dict.toList
                |> List.concatMap
                    (\( moduleName, moduleSpec ) ->
                        moduleSpec.types
                            |> Dict.toList
                            |> List.concatMap
                                (\( typeName, typeSpec ) ->
                                    case typeSpec.value of
                                        Type.CustomTypeSpecification params constructors ->
                                            constructors
                                                |> Dict.toList
                                                |> List.map
                                                    (\( ctorName, ctorArgs ) ->
                                                        ( ( packageName, moduleName, ctorName ), ( ( packageName, moduleName, typeName ), params, ctorArgs ) )
                                                    )

                                        _ ->
                                            []
                                )
                    )

        flattenDependencies : (PackageName -> Package.Specification () -> List ( FQName, a )) -> Dict FQName a
        flattenDependencies f =
            dependencies
                |> Dict.toList
                |> List.concatMap
                    (\( packageName, packageSpec ) ->
                        f packageName packageSpec
                    )
                |> Dict.fromList

        flattenLibrary : (PackageName -> Package.Specification () -> List ( FQName, a )) -> Dict FQName a
        flattenLibrary f =
            f libraryName (packageDef |> Package.definitionToSpecificationWithPrivate)
                |> Dict.fromList

        flatten : (PackageName -> Package.Specification () -> List ( FQName, a )) -> Dict FQName a
        flatten f =
            Dict.union
                (flattenDependencies f)
                (flattenLibrary f)
    in
    { valueSpecifications = flatten packageValueSpecifications
    , typeSpecifications = flatten packageTypeSpecifications
    , typeConstructors = flatten packageTypeConstructors
    }


{-| Look up a value specification by fully-qualified name. Dependencies will be included in the search.
-}
lookupValueSpecification : FQName -> IR -> Maybe (Value.Specification ())
lookupValueSpecification fqn ir =
    ir.valueSpecifications
        |> Dict.get fqn


{-| Look up a type specification by fully-qualified name. Dependencies will be included in the search.
-}
lookupTypeSpecification : FQName -> IR -> Maybe (Type.Specification ())
lookupTypeSpecification fqn ir =
    ir.typeSpecifications
        |> Dict.get fqn


{-| Look up a type constructor by fully-qualified name. Dependencies will be included in the search. The function
returns a tuple with the following elements:

  - The fully-qualified name of the type that this constructor belongs to.
  - The type arguments of the type.
  - The list of arguments (as name-type pairs) for this constructor.

-}
lookupTypeConstructor : FQName -> IR -> Maybe ( FQName, List Name, List ( Name, Type () ) )
lookupTypeConstructor fqn ir =
    ir.typeConstructors
        |> Dict.get fqn
