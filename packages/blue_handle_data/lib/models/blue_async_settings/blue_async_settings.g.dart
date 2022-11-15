// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blue_async_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetBlueAsyncSettingsCollection on Isar {
  IsarCollection<BlueAsyncSettings> get blueAsyncSettings => this.collection();
}

const BlueAsyncSettingsSchema = CollectionSchema(
  name: r'BlueAsyncSettings',
  id: -5830868907818864176,
  properties: {
    r'nameTasks': PropertySchema(
      id: 0,
      name: r'nameTasks',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 1,
      name: r'status',
      type: IsarType.byte,
      enumMap: _BlueAsyncSettingsstatusEnumValueMap,
    ),
    r'value': PropertySchema(
      id: 2,
      name: r'value',
      type: IsarType.longList,
    )
  },
  estimateSize: _blueAsyncSettingsEstimateSize,
  serialize: _blueAsyncSettingsSerialize,
  deserialize: _blueAsyncSettingsDeserialize,
  deserializeProp: _blueAsyncSettingsDeserializeProp,
  idName: r'id',
  indexes: {
    r'name_tasks': IndexSchema(
      id: 251331426331351612,
      name: r'name_tasks',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nameTasks',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'value': IndexSchema(
      id: -8658876004265234192,
      name: r'value',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'value',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _blueAsyncSettingsGetId,
  getLinks: _blueAsyncSettingsGetLinks,
  attach: _blueAsyncSettingsAttach,
  version: '3.0.4',
);

int _blueAsyncSettingsEstimateSize(
  BlueAsyncSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.nameTasks.length * 3;
  bytesCount += 3 + object.value.length * 8;
  return bytesCount;
}

void _blueAsyncSettingsSerialize(
  BlueAsyncSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.nameTasks);
  writer.writeByte(offsets[1], object.status.index);
  writer.writeLongList(offsets[2], object.value);
}

BlueAsyncSettings _blueAsyncSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BlueAsyncSettings(
    nameTasks: reader.readString(offsets[0]),
    status: _BlueAsyncSettingsstatusValueEnumMap[
            reader.readByteOrNull(offsets[1])] ??
        Status.enable,
    value: reader.readLongList(offsets[2]) ?? [],
  );
  return object;
}

P _blueAsyncSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (_BlueAsyncSettingsstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          Status.enable) as P;
    case 2:
      return (reader.readLongList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BlueAsyncSettingsstatusEnumValueMap = {
  'enable': 0,
  'disable': 1,
};
const _BlueAsyncSettingsstatusValueEnumMap = {
  0: Status.enable,
  1: Status.disable,
};

Id _blueAsyncSettingsGetId(BlueAsyncSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _blueAsyncSettingsGetLinks(
    BlueAsyncSettings object) {
  return [];
}

void _blueAsyncSettingsAttach(
    IsarCollection<dynamic> col, Id id, BlueAsyncSettings object) {}

extension BlueAsyncSettingsQueryWhereSort
    on QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QWhere> {
  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhere>
      anyNameTasks() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'name_tasks'),
      );
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhere> anyStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'status'),
      );
    });
  }
}

extension BlueAsyncSettingsQueryWhere
    on QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QWhereClause> {
  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      nameTasksEqualTo(String nameTasks) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name_tasks',
        value: [nameTasks],
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      nameTasksNotEqualTo(String nameTasks) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name_tasks',
              lower: [],
              upper: [nameTasks],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name_tasks',
              lower: [nameTasks],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name_tasks',
              lower: [nameTasks],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name_tasks',
              lower: [],
              upper: [nameTasks],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      nameTasksGreaterThan(
    String nameTasks, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name_tasks',
        lower: [nameTasks],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      nameTasksLessThan(
    String nameTasks, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name_tasks',
        lower: [],
        upper: [nameTasks],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      nameTasksBetween(
    String lowerNameTasks,
    String upperNameTasks, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name_tasks',
        lower: [lowerNameTasks],
        includeLower: includeLower,
        upper: [upperNameTasks],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      nameTasksStartsWith(String NameTasksPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name_tasks',
        lower: [NameTasksPrefix],
        upper: ['$NameTasksPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      nameTasksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name_tasks',
        value: [''],
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      nameTasksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'name_tasks',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'name_tasks',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'name_tasks',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'name_tasks',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      valueEqualTo(List<int> value) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'value',
        value: [value],
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      valueNotEqualTo(List<int> value) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'value',
              lower: [],
              upper: [value],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'value',
              lower: [value],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'value',
              lower: [value],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'value',
              lower: [],
              upper: [value],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      statusEqualTo(Status status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      statusNotEqualTo(Status status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      statusGreaterThan(
    Status status, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'status',
        lower: [status],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      statusLessThan(
    Status status, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'status',
        lower: [],
        upper: [status],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterWhereClause>
      statusBetween(
    Status lowerStatus,
    Status upperStatus, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'status',
        lower: [lowerStatus],
        includeLower: includeLower,
        upper: [upperStatus],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BlueAsyncSettingsQueryFilter
    on QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QFilterCondition> {
  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      nameTasksEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameTasks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      nameTasksGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameTasks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      nameTasksLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameTasks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      nameTasksBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameTasks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      nameTasksStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nameTasks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      nameTasksEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nameTasks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      nameTasksContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nameTasks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      nameTasksMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nameTasks',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      nameTasksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameTasks',
        value: '',
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      nameTasksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameTasks',
        value: '',
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      statusEqualTo(Status value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      statusGreaterThan(
    Status value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      statusLessThan(
    Status value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      statusBetween(
    Status lower,
    Status upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      valueElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: value,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      valueElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'value',
        value: value,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      valueElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'value',
        value: value,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      valueElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'value',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      valueLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'value',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      valueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'value',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      valueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'value',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      valueLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'value',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      valueLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'value',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterFilterCondition>
      valueLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'value',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension BlueAsyncSettingsQueryObject
    on QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QFilterCondition> {}

extension BlueAsyncSettingsQueryLinks
    on QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QFilterCondition> {}

extension BlueAsyncSettingsQuerySortBy
    on QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QSortBy> {
  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterSortBy>
      sortByNameTasks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameTasks', Sort.asc);
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterSortBy>
      sortByNameTasksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameTasks', Sort.desc);
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension BlueAsyncSettingsQuerySortThenBy
    on QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QSortThenBy> {
  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterSortBy>
      thenByNameTasks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameTasks', Sort.asc);
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterSortBy>
      thenByNameTasksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameTasks', Sort.desc);
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension BlueAsyncSettingsQueryWhereDistinct
    on QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QDistinct> {
  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QDistinct>
      distinctByNameTasks({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameTasks', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QDistinct>
      distinctByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value');
    });
  }
}

extension BlueAsyncSettingsQueryProperty
    on QueryBuilder<BlueAsyncSettings, BlueAsyncSettings, QQueryProperty> {
  QueryBuilder<BlueAsyncSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BlueAsyncSettings, String, QQueryOperations>
      nameTasksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameTasks');
    });
  }

  QueryBuilder<BlueAsyncSettings, Status, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<BlueAsyncSettings, List<int>, QQueryOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value');
    });
  }
}
