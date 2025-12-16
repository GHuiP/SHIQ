#!/usr/bin/env python3
import os
import shutil

def copy_png_files(source_dir, target_dir):
    """
    将源文件夹中的所有PNG文件复制到目标文件夹
    
    参数:
        source_dir: 源文件夹路径
        target_dir: 目标文件夹路径
    """
    # 确保目标文件夹存在
    if not os.path.exists(target_dir):
        os.makedirs(target_dir)
        print(f"创建目标文件夹: {target_dir}")
    
    # 获取源文件夹中的所有PNG文件
    png_files = [f for f in os.listdir(source_dir) if f.lower().endswith('.png')]
    
    if not png_files:
        print(f"源文件夹 {source_dir} 中没有PNG文件")
        return
    
    # 复制每个PNG文件到目标文件夹
    copied_count = 0
    for png_file in png_files:
        source_path = os.path.join(source_dir, png_file)
        target_path = os.path.join(target_dir, png_file)
        
        try:
            shutil.copy2(source_path, target_path)  # copy2保留文件元数据
            copied_count += 1
            print(f"已复制: {png_file}")
        except Exception as e:
            print(f"复制失败 {png_file}: {e}")
    
    print(f"\n复制完成！共复制 {copied_count} 个PNG文件到 {target_dir}")

if __name__ == "__main__":
    # 直接在代码中定义源文件夹和目标文件夹路径
    # 请根据您的实际需求修改这两个路径
    SOURCE_DIR = "/home/gyh/code/specularityRemovalTask/data/output/"  # 源文件夹路径
    TARGET_DIR = "/home/gyh/code/specularityRemovalTask/data/output/1.0/"    # 目标文件夹路径
    
    # 调用复制函数
    copy_png_files(SOURCE_DIR, TARGET_DIR)