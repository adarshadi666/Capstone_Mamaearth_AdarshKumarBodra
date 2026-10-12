# analysis/visualize.py
import os
import pandas as pd
import matplotlib.pyplot as plt

def generate_charts():
    # Make sure output directory exists
    os.makedirs("visualizations", exist_ok=True)
    
    # Read the cleaned merged data created by clean_and_eda.py
    df = pd.read_csv("analysis/cleaned_orders_merged.csv")

    # =========================================================================
    # Chart 1: Return rate by payment method (descending, with % on bars)
    # =========================================================================
    pm_summary = df.groupby('payment_method')['returned'].mean().reset_index()
    pm_summary['return_rate_pct'] = pm_summary['returned'] * 100
    pm_summary = pm_summary.sort_values(by='return_rate_pct', ascending=False)

    plt.figure(figsize=(7, 5))
    bars = plt.bar(
        pm_summary['payment_method'], 
        pm_summary['return_rate_pct'], 
        color=['#d9534f', '#5bc0de', '#0275d8'],
        width=0.55
    )

    # Label exact percentage on top of each bar
    for bar in bars:
        height = bar.get_height()
        plt.text(
            bar.get_x() + bar.get_width() / 2.0, 
            height + 1.0, 
            f"{height:.1f}%", 
            ha='center', 
            va='bottom', 
            fontsize=11, 
            fontweight='bold'
        )

    plt.title("COD Returns at 44.4% — 3x Card", fontsize=14, fontweight='bold', pad=15)
    plt.xlabel("Payment Method", fontsize=11, labelpad=8)
    plt.ylabel("Return Rate (%)", fontsize=11, labelpad=8)
    plt.ylim(0, 55)
    plt.grid(axis='y', linestyle='--', alpha=0.5)
    plt.tight_layout()
    
    chart1_path = "visualizations/return_rate_by_payment.png"
    plt.savefig(chart1_path, dpi=300)
    plt.close()
    print(f"[Chart 1] Successfully generated and saved: {chart1_path}")

    # =========================================================================
    # Chart 2: Outlier-corrected monthly revenue trend (naming actual peak month)
    # =========================================================================
    clean_df = df[~df['is_outlier']].copy()
    clean_df['month'] = pd.to_datetime(clean_df['order_date']).dt.strftime('%Y-%m')
    monthly_rev = clean_df.groupby('month')['order_value'].sum()

    plt.figure(figsize=(9, 5))
    plt.plot(
        monthly_rev.index, 
        monthly_rev.values, 
        marker='o', 
        linewidth=2.5, 
        markersize=7, 
        color='#2e7d32', 
        label='Outlier-Corrected Revenue'
    )

    # Highlight the true peak month (March 2026)
    peak_month = "2026-03"
    peak_val = monthly_rev[peak_month]
    plt.scatter([peak_month], [peak_val], color='#d9534f', s=120, zorder=5)
    plt.annotate(
        f"Actual Peak Month\nMarch 2026: ₹{peak_val:,.2f}",
        xy=(peak_month, peak_val),
        xytext=(0.5, 18500),
        arrowprops=dict(facecolor='black', shrink=0.08, width=1, headwidth=6),
        fontweight='bold',
        fontsize=10
    )

    plt.title("Outlier-Corrected Monthly Revenue: March 2026 is the True Peak Month", fontsize=13, fontweight='bold', pad=15)
    plt.xlabel("Order Month", fontsize=11, labelpad=8)
    plt.ylabel("Revenue (₹)", fontsize=11, labelpad=8)
    plt.ylim(8000, 23000)
    plt.grid(True, linestyle=':', alpha=0.6)
    plt.legend(loc='upper right')
    plt.tight_layout()

    chart2_path = "visualizations/monthly_revenue_trend.png"
    plt.savefig(chart2_path, dpi=300)
    plt.close()
    print(f"[Chart 2] Successfully generated and saved: {chart2_path}")

if __name__ == "__main__":
    generate_charts()