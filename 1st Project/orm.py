import sqlite3
from typing import Any, Dict, List, Optional, Type

class ValidationError(Exception):
    pass

class DoesNotExist(Exception):
    pass

class Database:
    _conn: Optional[sqlite3.Connection] = None
    _db_path: str = ':memory:'

    @classmethod
    def connect(cls, db_path: str = ':memory:'):
        if cls._conn:
            cls._conn.close()
        cls._db_path = db_path
        cls._conn = sqlite3.connect(db_path, check_same_thread=False)
        cls._conn.row_factory = sqlite3.Row
        return cls._conn

    @classmethod
    def get_conn(cls) -> sqlite3.Connection:
        if cls._conn is None:
            return cls.connect(cls._db_path)
        return cls._conn

    @classmethod
    def execute(cls, sql: str, params: tuple = ()) -> sqlite3.Cursor:
        conn = cls.get_conn()
        cur = conn.cursor()
        cur.execute(sql, params)
        conn.commit()
        return cur

class Field:
    sql_type = 'TEXT'

    def __init__(self, primary_key: bool = False, unique: bool = False,
                 default: Any = None, null: bool = False):
        self.primary_key = primary_key
        self.unique = unique
        self.default = default
        self.null = null
        self.name = None

    def validate(self, value):
        if value is None and not self.null and not self.primary_key:
            raise ValidationError(f"Field '{self.name}' cannot be null")

    def to_sql(self):
        parts = [self.sql_type]
        if self.primary_key:
            parts.append('PRIMARY KEY')
            if isinstance(self, IntegerField):
                parts.append('AUTOINCREMENT')
        if self.unique:
            parts.append('UNIQUE')
        if not self.null:
            parts.append('NOT NULL')
        if self.default is not None:
            if isinstance(self.default, str):
                parts.append(f"DEFAULT '{self.default}'")
            elif isinstance(self.default, bool):
                parts.append('DEFAULT ' + ('1' if self.default else '0'))
            else:
                parts.append(f'DEFAULT {self.default}')
        return ' '.join(parts)

class IntegerField(Field):
    sql_type = 'INTEGER'

    def validate(self, value):
        super().validate(value)
        if value is not None and not isinstance(value, int):
            raise ValidationError(f"Field '{self.name}' expects int, got {type(value).__name__}")

class CharField(Field):
    sql_type = 'TEXT'

    def __init__(self, max_length: int = 255, **kwargs):
        super().__init__(**kwargs)
        self.max_length = max_length

    def validate(self, value):
        super().validate(value)
        if value is not None:
            if not isinstance(value, str):
                raise ValidationError(f"Field '{self.name}' expects str, got {type(value).__name__}")
            if len(value) > self.max_length:
                raise ValidationError(f"Field '{self.name}' exceeds max_length {self.max_length}")

class BooleanField(Field):
    sql_type = 'INTEGER'

    def validate(self, value):
        super().validate(value)
        if value is not None and not isinstance(value, bool):
            raise ValidationError(f"Field '{self.name}' expects bool, got {type(value).__name__}")

class ModelMeta(type):
    def __new__(mcls, name, bases, attrs):
        if name == 'Model':
            return super().__new__(mcls, name, bases, attrs)
        fields = {}
        for k, v in list(attrs.items()):
            if isinstance(v, Field):
                v.name = k
                fields[k] = v
                attrs.pop(k)
        attrs['_fields'] = fields
        cls = super().__new__(mcls, name, bases, attrs)
        cls._create_table()
        return cls

class Model(metaclass=ModelMeta):
    _fields: Dict[str, Field]

    def __init__(self, **kwargs):
        self._data = {}
        for name, field in self._fields.items():
            self._data[name] = kwargs.get(name, field.default)

    @classmethod
    def _table_name(cls):
        return cls.__name__.lower()

    @classmethod
    def _create_table(cls):
        cols = []
        pk_present = any(f.primary_key for f in cls._fields.values())
        for name, field in cls._fields.items():
            cols.append(f"{name} {field.to_sql()}")
        if not pk_present:
            cols.insert(0, 'id INTEGER PRIMARY KEY AUTOINCREMENT')
        sql = f"CREATE TABLE IF NOT EXISTS {cls._table_name()} ({', '.join(cols)})"
        Database.execute(sql)

    def validate(self):
        for name, field in self._fields.items():
            value = self._data.get(name)
            field.validate(value)

    @classmethod
    def _row_to_instance(cls, row: sqlite3.Row):
        if row is None:
            return None
        return cls(**dict(row))

    def save(self):
        self.validate()
        fields = []
        values = []
        pk_name = None
        pk_value = None

        for name, field in self._fields.items():
            if field.primary_key:
                pk_name = name
                pk_value = self._data.get(name)
            else:
                fields.append(name)
                val = self._data.get(name)
                if isinstance(field, BooleanField) and val is not None:
                    val = 1 if val else 0
                values.append(val)

        table = self._table_name()

        if pk_name and pk_value is not None:
            set_clause = ', '.join([f"{f}=?" for f in fields])
            sql = f"UPDATE {table} SET {set_clause} WHERE {pk_name}=?"
            Database.execute(sql, tuple(values) + (pk_value,))
        else:
            cols_clause = ', '.join(fields)
            placeholders = ', '.join(['?' for _ in fields])
            sql = f"INSERT INTO {table} ({cols_clause}) VALUES ({placeholders})"
            try:
                cur = Database.execute(sql, tuple(values))
                if pk_name:
                    self._data[pk_name] = cur.lastrowid
                else:
                    self._data['id'] = cur.lastrowid
            except sqlite3.IntegrityError as e:
                raise ValidationError(str(e))
        return self

    @classmethod
    def create(cls, **kwargs):
        inst = cls(**kwargs)
        inst.save()
        return inst

    @classmethod
    def _build_where(cls, filters: Dict[str, Any]):
        if not filters:
            return ('', ())
        parts = []
        vals = []
        for k, v in filters.items():
            parts.append(f"{k}=?")
            if isinstance(v, bool):
                vals.append(1 if v else 0)
            else:
                vals.append(v)
        return (' WHERE ' + ' AND '.join(parts), tuple(vals))

    @classmethod
    def get(cls, **filters):
        table = cls._table_name()
        where, params = cls._build_where(filters)
        sql = f"SELECT * FROM {table}{where} LIMIT 1"
        cur = Database.execute(sql, params)
        row = cur.fetchone()
        if row is None:
            raise DoesNotExist(f"{cls.__name__} matching query does not exist")
        return cls._row_to_instance(row)

    @classmethod
    def filter(cls, **filters) -> List['Model']:
        table = cls._table_name()
        where, params = cls._build_where(filters)
        sql = f"SELECT * FROM {table}{where}"
        cur = Database.execute(sql, params)
        rows = cur.fetchall()
        return [cls._row_to_instance(r) for r in rows]

    def update(self, **kwargs):
        for k, v in kwargs.items():
            if k not in self._fields:
                raise AttributeError(k)
            self._data[k] = v
        return self.save()

    def delete(self):
        pk_name = None
        pk_value = None
        for name, field in self._fields.items():
            if field.primary_key:
                pk_name = name
                pk_value = self._data.get(name)
                break
        if pk_name is None:
            pk_name = 'id'
            pk_value = self._data.get('id')
        if pk_value is None:
            raise ValidationError('Cannot delete object without primary key')
        sql = f"DELETE FROM {self._table_name()} WHERE {pk_name}=?"
        Database.execute(sql, (pk_value,))

    def to_dict(self):
        return dict(self._data)
