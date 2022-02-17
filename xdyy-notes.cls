%
% Copyright (c) 2022 Kangwei Xia
% Released under the LaTeX Project Public License v1.3c License.
% Repository: https://gitee.com/xkwxdyy/xdyy-notes
%

\NeedsTeXFormat{LaTeX2e}[2017/04/15]
\RequirePackage{expl3}
\RequirePackage{xparse}
\ProvidesExplClass {xdyy-notes} {2022-02-17} {v0.0.1} 
  {A LaTeX class for taking math notes.}

% 检查 LaTeX2e kernel 版本
\msg_new:nnn { xdyy-notes } { latex-too-old }
  { TeX~ Live~ 2020~ or~ later~ version~ is~ required~ to~ compile~ this~ document. }
\@ifl@t@r \fmtversion { 2020/02/02 }
  { }
  { \msg_fatal:nn { xdyy-notes } { latex-too-old } }

% 检查编译引擎，要求使用 XeLaTeX。
\msg_new:nnn { xdyy-notes } { incompatible-engine }
  { XeLaTeX~ is~ required~ to~ compile~ this~ document. }

\sys_if_engine_xetex:F
  { \msg_fatal:nn { xdyy-notes } { incompatible-engine } }


% 使用 l3keys 定义 \xdyynotesetup 配置命令
\NewDocumentCommand \xdyynotesetup { m }
  { \keys_set:nn { xdyy-notes } {#1} }

\keys_define:nn { xdyy-notes }
  { 
    info .meta:nn = { xdyy-notes / info } {#1},
    signature .meta:nn = { xdyy-notes / signature } {#1},
    hyperref .meta:nn = { xdyy-notes / hyperref }{#1},
    style .meta:nn = { xdyy-notes / style }{#1},
  }


% 加载文档类和宏包

% 处理文档类选项
\PassOptionsToClass { UTF8 , a4paper , scheme = chinese , oneside } { ctexbook }
\DeclareOption* { \PassOptionsToClass { \CurrentOption } { ctexbook } }
\ProcessOptions*

\RequirePackage { filehook }
\AtEndOfPackageFile* { fontspec }
  { \msg_redirect_name:nnn { fontspec } { no-script } { none } }
\AtEndOfPackageFile* { xeCJK }
  {
    \msg_redirect_name:nnn { xeCJK } { CJKfamily-redef } { none }
    \defaultCJKfontfeatures
      {
        Script  = CJK,
        Mapping = fullwidth-stop ,
      }
  }

% 载入 \cls{ctexbook} 文档类。
\LoadClass { ctexbook }

% 要求 ctex v2.4.9 2017-04-01 或更高的版本。
\msg_new:nnn { xdyy-notes } { require-package-version }
  { The~ package~ "#1"~ is~ required. }

\@ifclasslater { ctexbook } { 2017/04/01 }
  { }
  {
    \msg_fatal:nnn { xdyy-notes } { require-package-version }
      { ctex~ v2.4.9~ 2017-04-01 }
  }

% 建议在模板开始处载入全部宏包，不要轻易改变加载顺序。
\RequirePackage { etoolbox }
\RequirePackage { geometry }
\RequirePackage { fontspec }
\RequirePackage { xeCJK }
\RequirePackage { xeCJKfntef }
\RequirePackage { fancyhdr }
\RequirePackage { lastpage }
\RequirePackage { amsmath }
\RequirePackage { enumitem }
\RequirePackage { xcolor }
\RequirePackage { needspace }
\RequirePackage { varwidth }
\RequirePackage { biblatex }

% 处理参考文献
\PassOptionsToPackage 
  {
    backend = biber, 
    natbib,
    style = gb7714-2015
  }
  { biblatex }

\tl_new:N \l__xdyynotes_bib_resource_tl

\keys_define:nn { xdyy-notes / style }
  {
    bib-resource .tl_set:N = \l__xdyynotes_bib_resource_tl,
    % bib-resource .initial:n = {xdyy-notes-template.bib}
  }

\AtEndPreamble
  {
    \exp_args:NV \addbibresource \l__xdyynotes_bib_resource_tl
  }

% 由于 mathtools 需要在 unicode-math 前载入，所以推迟载入 unicode-math
\AtBeginOfPackageFile* { siunitx }
  { \RequirePackage { unicode-math } }
\AtEndPreamble
  { \RequirePackage { unicode-math } }


% 对冲突的宏包报错。
\msg_new:nnn { xdyy-notes } { package-conflict }
  { The~ "#2"~ package~ is~ incompatible~ with~ "#1". }

\cs_new:Npn \xdyynotes_package_conflict:nn #1#2
  {
    \AtEndOfPackageFile* {#1}
      {
        \AtBeginOfPackageFile* {#2}
          { \msg_error:nnnn { xdyy-notes } { package-conflict } {#1} {#2} }
      }
  }

\xdyynotes_package_conflict:nn { unicode-math } { amscd }
\xdyynotes_package_conflict:nn { unicode-math } { amsfonts }
\xdyynotes_package_conflict:nn { unicode-math } { amssymb }
\xdyynotes_package_conflict:nn { unicode-math } { bbm }
\xdyynotes_package_conflict:nn { unicode-math } { bm }
\xdyynotes_package_conflict:nn { unicode-math } { eucal }
\xdyynotes_package_conflict:nn { unicode-math } { eufrak }
\xdyynotes_package_conflict:nn { unicode-math } { mathrsfs }
\xdyynotes_package_conflict:nn { unicode-math } { newtxmath }
\xdyynotes_package_conflict:nn { unicode-math } { upgreek }

\xdyynotes_package_conflict:nn { enumitem } { paralist }


% 个人信息接口
\tl_new:N \l__xdyynotes_info_author_tl
\tl_new:N \l__xdyynotes_info_title_tl
\tl_new:N \l__xdyynotes_info_date_tl

\keys_define:nn { xdyy-notes / info }
  {
    author .tl_set:N = \l__xdyynotes_info_author_tl,
    title .tl_set:N = \l__xdyynotes_info_title_tl,
    date .tl_set:N = \l__xdyynotes_info_date_tl,
    date .initial:n = {\today}
  }

\title
  {
    \bfseries \tl_use:N \l__xdyynotes_info_title_tl
  }

\author
  {
    \tl_use:N \l__xdyynotes_info_author_tl
  }

\date
  {
    \tl_use:N \l__xdyynotes_info_date_tl 
  }


% 设置hyperref
\clist_new:N \g__xdyynotes_to_hyperref_clist

\NewDocumentCommand \hypersetup { m }
  { \xdyynotes_hyperref_setup:n {#1} }
\cs_new_protected:Npn \xdyynotes_hyperref_setup:n #1
  { \clist_gput_right:Nn \g__xdyynotes_to_hyperref_clist {#1} }
\cs_new_protected:Npn \__xdyynotes_define_hyperlink_color:nnn #1#2#3
  {
    \definecolorset { HTML } { xdyynotes@ } { }
      { link, #1; url, #2; cite, #3 }
  }
\cs_new:Npn \__xdyynotes_set_hyperlink_color_key:n #1
  {
    \__xdyynotes_define_hyperlink_color:nnn
      { \clist_item:nn {#1} {2} }
      { \clist_item:nn {#1} {3} }
      { \clist_item:nn {#1} {4} }
    \xdyynotes_hyperref_setup:n
      {
        linkcolor = xdyynotes@link, linkbordercolor = xdyynotes@link,
        urlcolor  = xdyynotes@url,  urlbordercolor  = xdyynotes@url,
        citecolor = xdyynotes@cite, citebordercolor = xdyynotes@cite
      }
  }


% 直接用fduthesis修改颜色的做法会出问题（可能是一体性强）
% 稍微做点修改
\str_new:N \l__xdyynotes_hyperref_color_str

\cs_new:Nn \__xdyynotes_hyperref_color_set:
  {
    \str_case:VnF \l__xdyynotes_hyperref_color_str
      {
        { autumn }{ \__xdyynotes_set_hyperlink_color_key:n { autumn,    D70000, D75F00, AF8700 } }
        { business }{ \__xdyynotes_set_hyperlink_color_key:n { business,  D14542, 295497, 1F6E43 }} 
        { classic }{ \__xdyynotes_set_hyperlink_color_key:n { classic,   FF0000, 0000FF, 00FF00 } }
        { default }{ \__xdyynotes_set_hyperlink_color_key:n { default,   990000, 0000B2, 007F00 } }
        { elegant }{ \__xdyynotes_set_hyperlink_color_key:n { elegant,   961212, C31818, 9B764F } }
        { fantasy }{ \__xdyynotes_set_hyperlink_color_key:n { fantasy,   FF4A19, FF3F94, 934BA1 } }
        { material }{ \__xdyynotes_set_hyperlink_color_key:n { material,  E91E63, 009688, 4CAF50 } }
        { science }{ \__xdyynotes_set_hyperlink_color_key:n { science,   CA0619, 389F9D, FF8920 } }
        { summer }{ \__xdyynotes_set_hyperlink_color_key:n { summer,    00AFAF, 5F5FAF, 5F8700 } }
        { graylevel }{ \__xdyynotes_set_hyperlink_color_key:n { graylevel, 616161, 616161, 616161 } }
        { prl }{ \__xdyynotes_set_hyperlink_color_key:n { prl,       2D3092, 2D3092, 2D3092 } }
      }{\fail}
  }
\keys_define:nn { xdyy-notes / hyperref }
  {
    hyperlink-color .code:n = 
      {
        \str_set:Nn \l__xdyynotes_hyperref_color_str {#1}
        \__xdyynotes_hyperref_color_set:
      },
    hyperlink-color .value_required:n = true,
    hyperlink-color .initial:n = prl,
  }


\ctex_at_end_preamble:n
  {
    \RequirePackage { hyperref }
    \hypersetup
      {
        bookmarksnumbered = true,
        psdextra          = true,
        unicode           = true,
        pdftitle    = \l__xdyynotes_info_title_tl,
        pdfauthor   = \l__xdyynotes_info_author_tl,
        colorlinks = true,
      }
    \exp_args:NV \hypersetup \g__xdyynotes_to_hyperref_clist
    \xdyynotes_allow_url_break:
  }


% 允许url断行，来自fduthesis
\cs_new:Npn \xdyynotes_allow_url_break:
  {
    \cs_new:Npn \__xdyynotes_add_url_break_points:
      { \tl_map_function:NN \c__xdyynotes_url_break_points_tl \do }
    \__xdyynotes_appto_cmd:Nn \UrlBreaks
      { \UrlOrds \__xdyynotes_add_url_break_points: }
  }
\tl_const:Nn \c__xdyynotes_url_break_points_tl
  {
    abcdefghijklmnopqrstuvwxyz
    ABCDEFGHIJKLMNOPQRSTUVWXYZ
    0123456789
  }
\cs_new_protected:Npn \__xdyynotes_appto_cmd:Nn #1#2
  {
    \ctex_appto_cmd:NnnTF #1 { } {#2}
      { } { \ctex_patch_failure:N #1 }
  }


% 纸张和页面布局

\geometry
  {
    paper  = a4paper,
    margin = 1.1in,
    headheight = 13pt,
  }

\cs_generate_variant:Nn \int_to_arabic:n { v }
\cs_new:Npn \__xdyynotes_arabic:n #1
  { \int_to_arabic:v { c@ #1 } }


% ctex设置
\cs_new:Npn \__xdyynotes_chapternamebox:n #1
  {
    \begin{varwidth}{\hsize}
      \linespread{1}\selectfont
      \centering 
      #1
    \end{varwidth}
  }

\ctexset{
  contentsname = {Contents},
  chapter =
    {
      format      = \huge \normalfont \sffamily \raggedright ,
      name        = {Chapter \c_space_tl },
      nameformat  =
        {
          \rule{\linewidth}{1bp}
          \par\bigskip\hfill
          \__xdyynotes_chapternamebox:n
        },
      aftername   = \par,
      aftertitle  = 
        {
          \par\bigskip
          \nointerlineskip
          \rule{\linewidth}{2bp}
          \par
        },
      beforeskip  = 0 pt,
      afterskip   = 40 pt,
      number      = \__xdyynotes_arabic:n { chapter },
      fixskip     = true
    },
  section =
    {
      % name        = {\S},
      format     += \raggedright,
      break       = \Needspace{ .5\textwidth }
    },
  subsection =
    {
      % name        = {\S},
    },
  subsubsection =
    {
      % name        = {\S},
    },
  chapter / tocline =
    {
      \normalfont \sffamily
      \CTEXnumberline {#1} #2
    },
  section / tocline =
    {
      \CTEXnumberline {#1} #2
    },
  subsection / tocline =
    {
      \CJKfamily { zhkai }
      \CTEXnumberline {#1} #2
    }
}

% 去掉目录的页码
\patchcmd
  { \tableofcontents }
  { \@starttoc{toc} }
  { \thispagestyle{empty} \@starttoc{toc} }
  {}{}


% 字体

% 西文字体使用 New Computer Modern
\setmainfont { NewCM10 }
  [
    Extension      = .otf ,
    UprightFont    = *-Book ,
    BoldFont       = *-Bold ,
    ItalicFont     = *-BookItalic ,
    BoldItalicFont = *-BoldItalic ,
  ]
\setsansfont { NewCMSans10 }
  [
    Extension         = .otf ,
    UprightFont       = *-Book ,
    BoldFont          = *-Bold ,
    ItalicFont        = *-BookOblique ,
    BoldItalicFont    = *-BoldOblique ,
  ]
\setmonofont { NewCMMono10 }
  [
    Extension           = .otf ,
    UprightFont         = *-Book ,
    ItalicFont          = *-BookItalic ,
    BoldFont            = *-Bold ,
    BoldItalicFont      = *-BoldOblique ,
  ]

% 数学字体

% 按照国标样式配置 unicode-math

\tl_new:N \l__xdyynotes_save_leq_tl
\tl_new:N \l__xdyynotes_save_geq_tl
\AtEndOfPackageFile* { unicode-math }
  {
    \unimathsetup
      {
        math-style = ISO ,
        bold-style = ISO ,
        partial    = upright ,
      }
    \AtBeginDocument
      {
        \tl_set_eq:NN \leq \l__xdyynotes_save_leq_tl
        \tl_set_eq:NN \geq \l__xdyynotes_save_geq_tl
        \tl_set_eq:NN \leq \leqslant
        \tl_set_eq:NN \geq \geqslant
      }
    \cs_set_protected:Npn \mathellipsis { \mathinner { \unicodecdots } }
  }

\AtEndOfPackageFile* { unicode-math }
  {
    \setmathfont { NewCMMath-Book }
      [
        Extension    = .otf ,
        StylisticSet = 2 ,
      ]
    \setmathfont { NewCMMath-Book }
      [
        Extension    = .otf ,
        StylisticSet = 1 ,
        range        = { scr , bfscr } ,
      ]
    \setmathrm { NewCM10 }
      [
        Extension      = .otf ,
        UprightFont    = *-Book ,
        BoldFont       = *-Bold ,
        ItalicFont     = *-BookItalic ,
        BoldItalicFont = *-BoldItalic ,
      ]
    \setmathsf { NewCMSans10 }
      [
        Extension         = .otf ,
        UprightFont       = *-Book ,
        BoldFont          = *-Bold ,
        ItalicFont        = *-BookOblique ,
        BoldItalicFont    = *-BoldOblique ,
      ]
    \setmathtt { NewCMMono10 }
      [
        Extension           = .otf ,
        UprightFont         = *-Book ,
        ItalicFont          = *-BookItalic ,
        BoldFont            = *-Bold ,
        BoldItalicFont      = *-BoldOblique ,
      ]
  }


% 中文字体

% 在 ctex 的字体配置的基础上进行一些修改
% 将苹方和微软雅黑分别替换为华文黑体和中易黑体
\str_if_eq:onTF { \g__ctex_fontset_tl } { mac }
  {
    \setCJKsansfont { Heiti~ SC~ Light } [ BoldFont = Heiti~ SC~ Medium ]
  }
  {
    \str_if_eq:onT { \g__ctex_fontset_tl } { windows }
      { \setCJKsansfont { SimHei } }
  }

% 罗马数字使用中文字体
\xeCJKDeclareCharClass { CJK } { "2160 -> "217F }
% 带圈数字
\xeCJKDeclareCharClass { CJK } { "2460 -> "2473 }


% 如果有内容较高（如分式）使得行间距小于 0.5em，则将其增加至 0.5em。
\dim_set:Nn \lineskiplimit { .5em }
\skip_set:Nn \lineskip { .5em }



% unicode-math 的配置

% 兼容旧的粗体命令：\pkg{bm} 的 \cs{bm} 和 \pkg{amsmath} 的 \cs{boldsymbol}。
\AtEndOfPackageFile* { unicode-math }
  {
    \NewDocumentCommand \bm { m } { { \symbfit { ##1 } } }
    \RenewDocumentCommand \boldsymbol { m } { { \symbfit { ##1 } } }
    % 兼容 \pkg{amsfonts} 和 \pkg{amssymb} 中的一些命令。
    \NewDocumentCommand \square { } { \mdlgwhtsquare }
    \NewDocumentCommand \blacksquare { } { \mdlgblksquare }
    \AtBeginDocument
      { \RenewDocumentCommand \checkmark { } { \ensuremath{ ✓ } } }
  }


% 页眉和页脚

\tl_set:Nn \headrulewidth { 0.4pt }
% \cs_set_eq:NN \@mkboth \use_none:n
% \cs_set_eq:NN \sectionmark \use_none:n
% \cs_set_eq:NN \subsectionmark \use_none:n

\pagestyle { fancy }
\fancypagestyle { normalplain }
  {
    \fancyhf { }
    \fancyhead [ L ] 
      {
        \kaishu
        \leftmark
      }
    \fancyhead [ R ] 
      {
        \kaishu
        \rightmark
      }
    \fancyhead [ C ]
      {
        \kaishu \bfseries
        \tl_use:N \l__xdyynotes_info_title_tl
      }
    \fancyfoot [ C ]
      {
        \small
        Page~\thepage / \pageref { LastPage }
      }
  }
\pagestyle { normalplain }


% 重新修改chapter的plain
\fancypagestyle { plain }
  {
    \tl_set:Nn \headrulewidth { 0pt }
    \fancyhf {} 
    \fancyfoot [ C ]
      {
        \small
        Page~\thepage / \pageref { LastPage }
      }
  }


% 重设\frontmatter和\mainmatter，去掉frontmatter的页脚
\cs_set_eq:NN \__xdyynotes_frontmatter: \frontmatter
\cs_set_eq:NN \__xdyynotes_mainmatter: \mainmatter
\cs_set:Npn \frontmatter
  {
    \group_begin:
      \tl_set:Nn \headrulewidth { 0pt }
      \fancypagestyle { plain }
        { \fancyhf {} }
      \pagestyle { plain }
      \__xdyynotes_frontmatter:
  }
\cs_set:Npn \mainmatter
  {
    \group_end:
    \__xdyynotes_mainmatter:
  }


% 设置 enumitem 列表格式
\setlist{nosep}

\setlist[enumerate, 2]{
  left       = 2em,
  labelsep   = 0pt,
  label = { （ \arabic * ） }
}


% 正体的 e 和 i
\NewDocumentCommand \eu { } { \mathrm{ e } }
\NewDocumentCommand \iu { } { \mathrm{ i } }


% 兼容 siunitx v2.x 的一些命令
\AtEndOfPackageFile* { siunitx }
  {
    \ProvideDocumentCommand \unit       { } { \si }
    \ProvideDocumentCommand \qty        { } { \SI }
    \ProvideDocumentCommand \qtyproduct { } { \SI }
  }


% 前言
\NewDocumentEnvironment { preface } { O{} +b }
  {
    \chapter*{Preface}
    #2
  }
  {
    \vfil
    \signature[#1] 
    \vfil
  }


% 前言的签名落款
\tl_new:N \l__xdyynotes_signature_name_tl
\tl_new:N \l__xdyynotes_signature_place_tl
\tl_new:N \l__xdyynotes_signature_date_tl

\keys_define:nn { xdyy-notes / signature }
  {
    name .tl_set:N = \l__xdyynotes_signature_name_tl,
    name .initial:n = {夏康玮},
    place .tl_set:N = \l__xdyynotes_signature_place_tl,
    place .initial:n = {珞珈山},
    date .tl_set:N = \l__xdyynotes_signature_date_tl,
    date .initial:n = {\today}
  }

% \signature 签名落款命令
% 姓名、地点、时间
% 夏康玮于珞珈山
% 2022年2月17日
\NewDocumentCommand { \signature } { O{} }
  {
    \group_begin:
      \keys_set:nn { xdyy-notes / signature } {#1}
      \begin{flushright}
        \begin{tabular}{c}
          \l__xdyynotes_signature_name_tl
          于
          \l__xdyynotes_signature_place_tl \\
          \l__xdyynotes_signature_date_tl
        \end{tabular}
      \end{flushright}
    \group_end:
  }


