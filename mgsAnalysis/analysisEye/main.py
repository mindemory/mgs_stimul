import generate_masterdf as gm
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from generate_plots import subject_wise_error_plot

df = gm.master_df
n_rows_original = len(df)
# Filter out entries with 'rejtrials' == 1
df_filtered = df[df['rejtrials'] != 1].copy()
n_rows_filtered = len(df_filtered)
print(f"Original = {n_rows_original}, after filtering = {n_rows_filtered} trials.")


# Define the desired order

print(df.head())

subject_wise_error_plot(df_filtered, 'fsacc_err')
# 

# Plot the distribution
# fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
# sns.violinplot(data=df_filtered, x='TMS_condition', y='isacc_err', hue='ispro_condition', split=True, alpha = 0.2, ax=ax1)
# ax1.set_title('Distribution of isacc_err')
# ax1.legend(title='ispro_condition')
# sns.violinplot(data=df_filtered, x='TMS_condition', y='fsacc_err', hue='ispro_condition', split=True, alpha = 0.2, ax=ax2)
# ax2.set_title('Distribution of fsacc_err')
# ax2.legend(title='ispro_condition')

# # Create a separate dataframe with mean and error for each subjID
# mean_df = df_filtered.groupby(['TMS_condition', 'ispro_condition', 'subjID']).agg({'isacc_err': 'median', 'fsacc_err': 'median'}).reset_index()
# palette = sns.color_palette("viridis", n_colors=len(df_filtered['subjID'].unique()))
# # Plot the means and error bars
# for ax in [ax1, ax2]:
#     sns.pointplot(data=mean_df, x='TMS_condition', y='isacc_err', hue='ispro_condition', dodge=True, palette=palette, markers='o', errwidth=1, capsize=0.2, ax=ax, ci=95, alpha=0.7, join=False, position=50)
#     sns.pointplot(data=mean_df, x='TMS_condition', y='fsacc_err', hue='ispro_condition', dodge=True, palette=palette, markers='^', errwidth=1, capsize=0.2, ax=ax, ci=95, alpha=0.7, join=False, position=-5)
#     for ispro in [0, 1]:
#         for tms in order:
#             ispro_df = mean_df[(mean_df['ispro_condition'] == ('pro' if ispro else 'anti')) & (mean_df['TMS_condition'] == tms)]
#             y_isacc = ispro_df['isacc_err'].mean()
#             y_fsacc = ispro_df['fsacc_err'].mean()
#             n_subj = len(ispro_df)
#     ax.legend_.remove()
#     handles, labels = ax.get_legend_handles_labels()
#     ax.legend(handles[:2], labels[:2], title='ispro_condition', loc='upper left')
#     for handle in handles[2:]:
#         handle.set_visible(False)
# plt.show()
# fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
# mean_df = df_filtered.groupby(['TMS_condition', 'ispro_condition', 'subjID']).agg({'isacc_err': 'mean', 'fsacc_err': 'mean'}).reset_index()
# print(df_filtered.head())
# print(df_filtered.shape)
# palette = sns.color_palette("viridis", n_colors=len(df_filtered['subjID'].unique()))
# sns.pointplot(data=df_filtered, x='TMS_condition', y='isacc_err', hue='ispro_condition', dodge=-0.2, linestyles='--', errwidth = 0.5,
#               palette=palette, markers='o', errorbar = 'se', ax=ax1)
# sns.pointplot(data=df_filtered, x='TMS_condition', y='fsacc_err', hue='ispro_condition', dodge=-0.2, linestyles='--', errwidth = 0.5,
#               palette=palette, markers='o', errorbar = 'se', ax=ax2)


# plt.show()