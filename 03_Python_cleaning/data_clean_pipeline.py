import pandas as pd
import unicodedata
import re

#1. Check type of data 
'''
check_type
│
├── 1. Loop schema
│     └── for col, dtype
│
├── 2. Check tồn tại
│     └── if col not in df → skip
│
├── 3. Chuẩn hóa dtype
│     └── lower()
│
├── 4. Casting (trái tim của hàm)
│     ├── int      → to_numeric → Int64
│     ├── float    → to_numeric
│     ├── str      → astype('string')
│     └── datetime → to_datetime
│
├── 5. Error handling
│     └── try / except
│
└── 6. return df
'''
def check_type(df, schema):
    for col, dtype in schema.items():
        if col not in df.columns:
            continue

        dtype = str(dtype).lower()

        try:
            if dtype == 'int':
                df[col] = pd.to_numeric(df[col], errors='coerce').astype('Int64')

            elif dtype == 'float':
                df[col] = pd.to_numeric(df[col], errors='coerce')

            elif dtype == 'str':
                df[col] = df[col].astype('string')

            elif dtype == 'datetime':
                df[col] = pd.to_datetime(df[col], errors='coerce')#to_datetime() xử lý format linh hoạt 

        except Exception as e:
            print(f"Error casting column {col}: {e}")

    return df


#2. Clean text
'''
clean_short_text
│
├── 1. Check null
│     └── nếu NaN → return None
│
├── 2. Chuẩn hóa kiểu
│     └── str(text)
│
├── 3. Xóa khoảng trắng thừa
│     ├── strip() (đầu/cuối)
│     └── regex \s+ → 1 space
│
├── 4. Chuẩn hóa Unicode
│     └── normalize('NFC')
│
├── 5. Xóa ký tự đặc biệt
│     └── regex [^\w\s]
│
├── 6. Lowercase
│     └── text.lower()
│
└── 7. Return text sạch 

một số cái cần học:
re.sub(r'[^\w\s]', '', text) --> xóa kí tự đặc biệt
re.sub(r'[^a-zA-Z0-9]', '', text) -->giữ chữ và số, còn lại xóa hết 
re.sub(r'\d', '', text) --> xóa số
re.sub(r'[a-zA-Z]', '', text) --> xóa chữ, chỉ giữ lại số
re.sub(r'\s+', ' ', text) --> xóa khoảng trắng dư
'''
def clean_short_text(text):
    if pd.isna(text):
        return None
    
    text = str(text).strip()
    text = re.sub(r'\s+', ' ', text)
    text = unicodedata.normalize('NFC', text)
    text = re.sub(r'[^\w\s]', '', text, flags=re.UNICODE)
    text = text.lower()
    
    return text
'''
clean_text_columns
│
├── Input
│     ├── df (DataFrame)
│     └── cols (list cột cần clean)
│
├── Loop từng cột
│     └── for col in cols
│
├── Check tồn tại
│     └── nếu col ∈ df.columns
│
├── Apply function
│     └── df[col].apply(clean_short_text)
│
└── Return df
'''

def clean_text_columns(df, cols):
    for col in cols:
        if col in df.columns:
            df[col] = df[col].apply(clean_short_text)
    return df
#3. Null flag
'''
check_null
│
├── Input
│     ├── df (DataFrame)
│     └── cols (list cột cần check)
│
├── Loop từng cột
│     └── for col in cols
│
├── Check tồn tại
│     └── nếu col ∈ df.columns
│
├── Tạo cột flag mới
│     └── flag_null_col
│
├── Detect null
│     └── df[col].isna()
│
├── Convert bool → int
│     └── True → 1
│         False → 0
│
└── Return df
'''
def check_null(df, cols):
    for col in cols:
        if col in df.columns:
            df[f'flag_null_{col}'] = df[col].isna().astype(int)
    return df
#4. Duplicate check
'''
check_duplicate
│
├── Input
│     ├── df (data)
│     ├── cols (cột dùng để check trùng)
│     └── keep_first (giữ dòng đầu hay không)
│
├── 1. Group data
│     └── groupby(cols)
│
├── 2. Đếm số lần xuất hiện
│     └── transform('size') → duplicate_count
│
├── 3. Đánh dấu duplicate
│     └── duplicate_count > 1 → 1 / 0
│
├── 4. (Optional) Xóa duplicate
│     └── drop_duplicates(subset=cols, keep='first')
│
└── 5. Return df
'''
def check_duplicate(df, cols, keep_first=True):
    df['duplicate_count'] = df.groupby(cols).transform('size')
    df['is_duplicate'] = (df['duplicate_count'] > 1).astype(int)
    
    if keep_first:
        df = df.drop_duplicates(subset=cols, keep='first')
    return df


#5. Business rule (single table)
'''
checK_column
│
├── Input
│     ├── df (DataFrame)
│     ├── flag_name (tên rule)
│     └── condition_func (hàm điều kiện)
│
├── 1. Áp dụng điều kiện
│     └── condition_func(df)
│
├── 2. Đảo điều kiện
│     └── ~ (NOT)
│
├── 3. Convert bool → int
│     └── True/False → 1/0
│
├── 4. Tạo cột flag
│     └── flag_invalid_<flag_name>
│
└── 5. Return df
'''
def checK_column(df, flag_name, condition_func):
    df[f'check_logic_{flag_name}'] = (~condition_func(df)).astype(int)
    return df


#6. Foreign key check
'''
check_foreign_key
│
├── Input
│     ├── df_main (bảng chính)
│     ├── df_ref (bảng tham chiếu)
│     ├── key_main (cột FK)
│     ├── key_ref (cột PK)
│     └── flag_name
│
├── 1. Check tồn tại cột
│     └── nếu thiếu → return luôn
│
├── 2. Kiểm tra FK hợp lệ
│     └── df_main[key_main].isin(df_ref[key_ref])
│
├── 3. Đảo điều kiện
│     └── ~ → invalid
│
├── 4. Convert bool → int
│     └── True/False → 1/0
│
├── 5. Tạo cột flag
│     └── flag_invalid_fk_<name>
│
└── Return df_main
'''
def check_foreign_key(df_main, df_ref, key_main, key_ref, flag_name):
    if key_main not in df_main.columns or key_ref not in df_ref.columns:
        return df_main

    df_main[f'flag_invalid_fk_{flag_name}'] = (
        ~df_main[key_main].isin(df_ref[key_ref])
    ).astype(int)

    return df_main


#7. Cross-table business rule
'''
check_logic_column_table
│
├── Input
│     ├── df_main (bảng chính)
│     ├── df_ref (bảng phụ)
│     ├── on (key join)
│     ├── flag_name
│     └── condition_func (rule)
│
├── 1. JOIN bảng
│     └── merge(on, how='left')
│
├── 2. Data sau join
│     └── df có thêm cột từ bảng ref
│
├── 3. Áp dụng rule
│     └── condition_func(df)
│
├── 4. Đảo điều kiện
│     └── ~ → invalid
│
├── 5. Convert bool → int
│     └── 1 = sai, 0 = đúng
│
├── 6. Tạo cột flag
│     └── flag_invalid_<name>
│
└── Return df
'''
def check_logic_column_table(df_main, df_ref, on, flag_name, condition_func):
    df = df_main.merge(df_ref, on=on, how='left')

    df[f'flag_logic_column_table_{flag_name}'] = (~condition_func(df)).astype(int)

    return df

#8. Outlier
#IQR
'''
check_outliers_iqr
│
├── Input
│   ├── df
│   └── cols
│
├── Loop từng col
│   ├── check tồn tại
│   ├── tính Q1 (25%)
│   ├── tính Q3 (75%)
│   ├── IQR = Q3 - Q1
│   │
│   ├── lower = Q1 - 1.5*IQR
│   ├── upper = Q3 + 1.5*IQR
│   │
│   ├── detect outliers
│   │   ├── < lower
│   │   └── > upper
│   │
│   └── tạo cột flag (0/1)
│
└── return df
'''
def check_outliers_iqr(df, cols):
    for col in cols:
        if col not in df.columns:
            continue
        
        Q1 = df[col].quantile(0.25)
        Q3 = df[col].quantile(0.75)
        IQR = Q3 - Q1

        lower = Q1 - 1.5 * IQR
        upper = Q3 + 1.5 * IQR

        df[f'flag_outliers_iqr_{col}'] = (
            (df[col] < lower) | (df[col] > upper)
        ).astype(int)
    return df
#ZSCORE
'''
check_outliers_zscore
│
├── Input
│   ├── df
│   ├── cols
│   └── threshold
│
├── Loop từng col
│   │
│   ├── check tồn tại
│   │
│   ├── tính mean
│   ├── tính std
│   │
│   ├── nếu std = 0
│   │   └── không có outlier
│   │
│   ├── tính z_score
│   │   └── (x - mean) / std
│   │
│   ├── detect outlier
│   │   └── |z| > threshold
│   │
│   └── tạo flag (0/1)
│
└── return df
'''
def check_outliers_zscore(df, cols, threshold=3):
    for col in cols:
        if col not in df.columns:
            continue
        
        mean = df[col].mean()
        std = df[col].std()

        # tránh chia cho 0
        if std == 0 or pd.isna(std):
            df[f'flag_outliers_zscore_{col}'] = 0
            continue

        z_score = (df[col] - mean) / std

        df[f'flag_outliers_zscore_{col}'] = (
            (z_score.abs() > threshold)
        ).astype(int)
    
    return df

#9. Summary 
'''
data_quality_summary
│
├── Input
│   ├── df
│   └── table_name
│
├── Loop columns
│   │
│   ├── Flag rate
│   │   └── mean(flag_col)
│   │
│   ├── Completeness
│   │   └── 1 - null_rate
│   │
│   ├── Unique rate
│   │   ├── count non-null
│   │   └── nunique / non-null
│
├── Table level
│   ├── duplicate_rate
│   └── row_count
│
├── Convert
│   └── dict → DataFrame
│
└── Output
    └── summary_df
'''
def data_quality_summary(df, table_name):
    summary = {}

    for col in df.columns:
        # flag
        if col.startswith('flag_'):
            summary[col] = df[col].mean()
            continue

        # completeness
        summary[f'completeness_{col}'] = 1 - df[col].isna().mean()

        # missing rate
        summary[f'missing_rate_{col}'] = df[col].isna().mean()

        # unique rate
        non_null = df[col].notna().sum()
        summary[f'unique_rate_{col}'] = df[col].nunique() / non_null if non_null > 0 else 0

    # duplicate
    summary['duplicate_rate'] = df.duplicated().mean()

    # row count
    summary['row_count'] = len(df)

    summary_df = pd.DataFrame([summary])
    summary_df['table_name'] = table_name

    return summary_df