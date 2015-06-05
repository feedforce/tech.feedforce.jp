---
title: 稼働中のEC2インスタンスにディスク(EBS)を追加する
date: 2015-06-05 17:00 JST
authors: masutaka
tags: aws
---

こんにちは。増田です。

このブログの記事の作成から公開まで、エンジニア以外の方向けに社内でデモすることになりました。
これはその記事です。

<!--more-->

## ディスクを追加

1. EC2の管理画面からELASTIC BLOCK STORE > Volumesに進み、希望サイズのボリュームを作る
![EC2_Management_Console.png](/images/2015/06/ebs-menu.png)
1. Available になったら、マウントしたいEC2インスタンスにAttachする
1. EC2インスタンスにsshログインし、ファイルシステムを作成、マウントする

    ```console
    $ ssh test1.example.jp
    $ ls -alF /dev/xvdk
    brw-rw---- 1 root disk 202, 160  4月  3 15:29 2015 /dev/xvdk
    
    $ sudo mkfs.ext4 /dev/xvdk
    mke2fs 1.41.12 (17-May-2010)
    Filesystem label=
    OS type: Linux
    Block size=4096 (log=2)
    Fragment size=4096 (log=2)
    Stride=0 blocks, Stripe width=0 blocks
    3932160 inodes, 15728640 blocks
    786432 blocks (5.00%) reserved for the super user
    First data block=0
    Maximum filesystem blocks=4294967296
    480 block groups
    32768 blocks per group, 32768 fragments per group
    8192 inodes per group
    Superblock backups stored on blocks: 
            32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
            4096000, 7962624, 11239424
    
    Writing inode tables: done                            
    Creating journal (32768 blocks): done
    Writing superblocks and filesystem accounting information: done
    
    This filesystem will be automatically checked every 33 mounts or
    180 days, whichever comes first.  Use tune2fs -c or -i to override.
    
    $ sudo mkdir /hoge
    $ sudo mount /dev/xvdk /hoge
    ```

1. 60GBのボリュームがマウントされた。

    ```console
    $ df /hoge
    Filesystem           1K-ブロック    使用   使用可 使用% マウント位置
    /dev/xvdk             61927420    184136  58597556   1% /hoge
    ```

## 他のEC2インスタンスに繋ぎかえる

他のEC2インスタンスでマウントすることも可能

1. unmount

    ```console
    $ sudo umount /hoge
    ```

1. EC2の管理画面からDetach、マウントしたいEC2インスタンスにAttachする
1. マウントしたいEC2インスタンスにsshログインし、mountする

    ```console
    $ ssh test2.example.jp
    $ sudo mkdir /hoge
    $ sudo mount /dev/xvdk /hoge
    ```
