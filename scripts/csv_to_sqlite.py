#!/usr/bin/env python3
"""Convert team_data/plays.csv into an SQLite database team_data/plays.db.

Rules:
- Table name: plays
- Try to import numeric columns as integers when possible, otherwise as floats.
- Non-numeric columns remain TEXT.
"""
import os
import sqlite3
import sys
from typing import List

import numpy as np
import pandas as pd


def infer_and_cast(df: pd.DataFrame) -> pd.DataFrame:
    """Try to convert columns to numeric types (int or float) when feasible.

    Strategy:
    - For each column, attempt pd.to_numeric(..., errors='coerce').
    - If the converted series has no NaNs and all values are integer-like -> cast to int64.
    - If it has NaNs or non-integers but at least one numeric -> cast to float64.
    - Otherwise leave as object/string.
    """
    out = df.copy()
    for col in df.columns:
        s = df[col]
        # try numeric conversion
        conv = pd.to_numeric(s, errors='coerce')
        if conv.notna().all():
            # all values numeric
            # check integer-likeness
            if np.all(np.equal(conv, conv.astype(np.int64))):
                out[col] = conv.astype(np.int64)
            else:
                out[col] = conv.astype(np.float64)
        else:
            # some non-numeric or missing values
            # if at least one numeric value, keep as float (to allow NaN)
            if conv.notna().any():
                out[col] = conv.astype(np.float64)
            else:
                # keep original (likely text)
                out[col] = s
    return out


def main(csv_path: str = "team_data/plays.csv", db_path: str = "team_data/plays.db") -> int:
    if not os.path.exists(csv_path):
        print(f"CSV not found: {csv_path}")
        return 2

    print(f"Reading CSV: {csv_path}")
    # Let pandas infer types with low_memory=False for more accurate inference
    df = pd.read_csv(csv_path, low_memory=False)
    print(f"Rows: {len(df)}, Columns: {len(df.columns)}")

    print("Inferring numeric columns and casting...")
    df2 = infer_and_cast(df)

    # show a small summary of inferred dtypes
    print("Inferred column dtypes:")
    for c in df2.columns:
        print(f"  {c}: {df2[c].dtype}")

    # write to sqlite
    os.makedirs(os.path.dirname(db_path) or ".", exist_ok=True)
    print(f"Writing SQLite DB: {db_path} (table name: plays)")
    conn = sqlite3.connect(db_path)
    try:
        df2.to_sql("plays", conn, if_exists="replace", index=False)
    finally:
        conn.close()

    print("Done.")
    return 0


if __name__ == "__main__":
    csv = sys.argv[1] if len(sys.argv) > 1 else "team_data/plays.csv"
    db = sys.argv[2] if len(sys.argv) > 2 else "team_data/plays.db"
    raise SystemExit(main(csv, db))
