%
% Copyright (c) 2022 Kangwei Xia
% Released under the LaTeX Project Public License v1.3c License.
% Repository: https://gitee.com/xkwxdyy/xdyy-notes
%

\NeedsTeXFormat{LaTeX2e}[2017/04/15]
\RequirePackage{expl3}
\RequirePackage{xparse}
\ProvidesExplClass {xdyy-notes} {2022-02-20} {v0.0.2} 
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
\NewDocumentCommand \xdyynotesetup { +m }
  { \keys_set:nn { xdyy-notes } {#1} }

\keys_define:nn { xdyy-notes }
  { 
    info .meta:nn = { xdyy-notes / info } {#1},
    signature .meta:nn = { xdyy-notes / signature } {#1},
    hyperref .meta:nn = { xdyy-notes / hyperref }{#1},
    style .meta:nn = { xdyy-notes / style }{#1},
    quotation .meta:nn = { xdyy-notes / quotation }{#1},
    detail .meta:nn = { xdyy-notes / detail }{#1},
    exercise .meta:nn = { xdyy-notes / exercise }{#1},
    correction .meta:nn = { xdyy-notes / correction }{#1},
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
\RequirePackage [dvipsnames, svgnames]{ xcolor }
\RequirePackage { needspace }
\RequirePackage { varwidth }
\RequirePackage { biblatex }
\RequirePackage { amsthm }
\RequirePackage { thmtools }
\RequirePackage [ most ] { tcolorbox }

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
  left       = 0em,
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
\NewDocumentEnvironment { preface } { +O{} +b }
  {
    \chapter*{Preface}
    #2
  }
  {
    \vfil
    \group_begin:
      \keys_set:nn { xdyy-notes } {#1}
      \signature
    \group_end:
    \vfil
  }


% 前言的签名落款 \signature 命令
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


% 引用环境 quotation

\cs_new:Npn \__xdyynotes_quotation_define_input_tl:n #1
  {
    \tl_new:c { l__xdyynotes_quotation_ #1 _input_tl }
  }

\cs_new:Npn \__xdyynotes_quotation_define_output_tl:n #1
  {
    \tl_new:c { l__xdyynotes_quotation_ #1 _output_tl }
  }

\clist_map_function:nN
  { title, book, paper, author, year, edition, page }
  \__xdyynotes_quotation_define_input_tl:n

\clist_map_function:nN
  { title, book, paper, author, year, edition, page }
  \__xdyynotes_quotation_define_output_tl:n


\keys_define:nn { xdyy-notes / quotation }
  {
    title .tl_set:N = \l__xdyynotes_quotation_title_input_tl,
    book .tl_set:N = \l__xdyynotes_quotation_book_input_tl,
    paper .tl_set:N = \l__xdyynotes_quotation_paper_input_tl,
    author .tl_set:N = \l__xdyynotes_quotation_author_input_tl,
    year .tl_set:N = \l__xdyynotes_quotation_year_input_tl,
    edition .tl_set:N = \l__xdyynotes_quotation_edition_input_tl,
    page .tl_set:N = \l__xdyynotes_quotation_page_input_tl,
  }

\declaretheorem
  [
    name    = 引用,
    refname = 引用,
    within  = section
  ]{Quotation}

\cs_new:Nn \__xdyynotes_quotation_page_set:
  {
    \tl_if_blank:VF \l__xdyynotes_quotation_page_input_tl
      {
        \tl_set:Nn \l__xdyynotes_quotation_page_output_tl
          {
            Page:~ \l__xdyynotes_quotation_page_input_tl
          }
      }
  }

\cs_new:Nn \__xdyynotes_quotation_title_set:
  {
    \bool_if:nTF
      {
        \tl_if_blank_p:V \l__xdyynotes_quotation_book_input_tl
        &&
        \tl_if_blank_p:V \l__xdyynotes_quotation_paper_input_tl
      }
      {
        \tl_set:Nn \l__xdyynotes_quotation_title_output_tl 
          {
            \l__xdyynotes_quotation_title_input_tl
            \l__xdyynotes_quotation_edition_output_tl
          }
      }
      {
        % 先对book或paper的input进行处理
        \__xdyynotes_quotation_book_output_set:
        \__xdyynotes_quotation_paper_output_set:
        % 然后再赋值给title的output
        \tl_if_blank:VTF \l__xdyynotes_quotation_book_input_tl
          {
            \tl_set:Nn \l__xdyynotes_quotation_title_output_tl 
              {
                \l__xdyynotes_quotation_paper_output_tl
              }
          }
          {
            \tl_set:Nn \l__xdyynotes_quotation_title_output_tl 
              {
                \l__xdyynotes_quotation_book_output_tl
              }
          }
      }
  }

\cs_new:Nn \__xdyynotes_quotation_paper_output_set:
  {
    \tl_set:Nn \l__xdyynotes_quotation_paper_output_tl
      {
        \group_begin:
          \normalfont
          \l__xdyynotes_quotation_paper_input_tl
          \l__xdyynotes_quotation_edition_output_tl
        \group_end:
      }
  }

\cs_new:Nn \__xdyynotes_quotation_book_output_set:
  {
    \tl_set:Nn \l__xdyynotes_quotation_book_output_tl
      {
        \group_begin:
          \itshape 
          \l__xdyynotes_quotation_book_input_tl
          \l__xdyynotes_quotation_edition_output_tl
        \group_end:
      }
  }

\cs_new:Nn \__xdyynotes_quotation_author_set:
  {
    \tl_if_blank:VF \l__xdyynotes_quotation_author_input_tl
      {
        \tl_set:Nn \l__xdyynotes_quotation_author_output_tl
          {
            \group_begin:
              \normalfont \l__xdyynotes_quotation_author_input_tl
            \group_end:
            .~
          }
      }
  }

\cs_new:Nn \__xdyynotes_quotation_year_set:
  {
    \tl_if_blank:VF \l__xdyynotes_quotation_year_input_tl
      {
        \tl_set:Nn \l__xdyynotes_quotation_year_output_tl
          {
            , ~
            \group_begin:
              \normalfont \l__xdyynotes_quotation_year_input_tl.
            \group_end:
          }
      }
  }

\cs_new:Nn \__xdyynotes_quotation_edition_set:
  {
    \tl_if_blank:VF \l__xdyynotes_quotation_edition_input_tl
      {
        \tl_set:Nn \l__xdyynotes_quotation_edition_output_tl
          { , ~\l__xdyynotes_quotation_edition_input_tl }
      }
  }

\RenewDocumentEnvironment { quotation } { +O{} +b }
  {
    \begin{Quotation}
      #2
  }
  {
      \par
      \group_begin:
        \keys_set:nn { xdyy-notes / quotation } {#1}
        % 设置title
        \__xdyynotes_quotation_title_set:
        % 设置版本
        \__xdyynotes_quotation_edition_set:
        % 设置作者
        \__xdyynotes_quotation_author_set:
        % 设置年份
        \__xdyynotes_quotation_year_set:
        % 设置页数
        \__xdyynotes_quotation_page_set:
        \begin{flushright}
          --- ~
          \l__xdyynotes_quotation_author_output_tl
          \l__xdyynotes_quotation_title_output_tl
          \l__xdyynotes_quotation_year_output_tl
          \quad 
          \l__xdyynotes_quotation_page_output_tl
        \end{flushright}
      \group_end:
    \end{Quotation}
  }

\tcolorboxenvironment { quotation }
  {
    enhanced~jigsaw, 
    parbox = false,
    breakable,
    left = 3mm,
    top  = 1mm,
    bottom = 4mm,
    right = 3mm,
    % blanker,
    frame~hidden,
    % boxrule = 0pt,
    before~skip = 10pt,
    after~skip = 10pt,
    borderline~west = {1mm}{0pt}{gray},
    colback = lightgray!20!white,
  }


% 细节补充环境 detail

% 声明变量
\cs_new:Npn \__xdyynotes_detail_define_input_tl:n #1
  {
    \tl_new:c { l__xdyynotes_detail_ #1 _input_tl }
  }

\cs_new:Npn \__xdyynotes_detail_define_output_tl:n #1
  {
    \tl_new:c { l__xdyynotes_detail_ #1 _output_tl }
  }

\clist_map_function:nN
  {
    book, paper, edition, author, 
    page, original, title, year
  }
  \__xdyynotes_detail_define_input_tl:n

\clist_map_function:nN
  {
    book, paper, edition, author, 
    page, original, title, year
  }
  \__xdyynotes_detail_define_output_tl:n

\keys_define:nn { xdyy-notes / detail }
  {
    book .tl_set:N = \l__xdyynotes_detail_book_input_tl,
    paper .tl_set:N = \l__xdyynotes_detail_paper_input_tl,
    edition .tl_set:N = \l__xdyynotes_detail_edition_input_tl,
    author .tl_set:N = \l__xdyynotes_detail_author_input_tl,
    page .tl_set:N = \l__xdyynotes_detail_page_input_tl,
    original .tl_set:N = \l__xdyynotes_detail_original_input_tl,
    title .tl_set:N = \l__xdyynotes_detail_title_input_tl,
    year .tl_set:N = \l__xdyynotes_detail_year_input_tl,
  }


\cs_new:Nn \__xdyynotes_detail_original_output_set:
  {
    \tl_set:Nn \l__xdyynotes_detail_original_output_tl
      {
        \textbf 
          % { 原文：}
          { 【原文】}
        \l__xdyynotes_detail_original_input_tl
      }
  }
\cs_new:Nn \__xdyynotes_detail_author_output_set:
  {
    \tl_if_blank:VF \l__xdyynotes_detail_author_input_tl
      {
        \tl_set:Nn \l__xdyynotes_detail_author_output_tl
          {
            \group_begin:
              \itshape \l__xdyynotes_detail_author_input_tl
            \group_end:
            .~
          }
      }
  }
\cs_new:Nn \__xdyynotes_detail_page_output_set:
  {
    \tl_if_blank:VF \l__xdyynotes_detail_page_input_tl
      {
        \tl_set:Nn \l__xdyynotes_detail_page_output_tl
          {
            \quad
            Page:~ \l__xdyynotes_detail_page_input_tl
          }
      }
  }
\cs_new:Nn \__xdyynotes_detail_edition_output_set:
  {
    \tl_if_blank:VF \l__xdyynotes_detail_edition_input_tl
      {
        \tl_set:Nn \l__xdyynotes_detail_edition_output_tl
          {
            , ~
            % \group_begin:
              \l__xdyynotes_detail_edition_input_tl
            % \group_end:
          }
      }
  }
\cs_new:Nn \__xdyynotes_detail_book_output_set:
  {
    \tl_set:Nn \l__xdyynotes_detail_book_output_tl
      {
        \group_begin:
          \itshape 
          \l__xdyynotes_detail_book_input_tl
          \l__xdyynotes_detail_edition_output_tl
        \group_end:
      }
  }
\cs_new:Nn \__xdyynotes_detail_paper_output_set:
  {
    \tl_set:Nn \l__xdyynotes_detail_paper_output_tl
      {
        \group_begin:
          \normalfont
          \l__xdyynotes_detail_paper_input_tl
          \l__xdyynotes_detail_edition_output_tl
        \group_end:
      }
  }
\cs_new:Nn \__xdyynotes_detail_title_output_set:
  {
    \__xdyynotes_detail_book_output_set:
    \__xdyynotes_detail_paper_output_set:
    \tl_if_blank:VTF \l__xdyynotes_detail_title_input_tl
      {
        \tl_if_blank:VTF \l__xdyynotes_detail_book_input_tl
          {
            % 如果book值是空的，就设置title为paper系列
            \tl_set:Nn \l__xdyynotes_detail_title_output_tl
              {
                \l__xdyynotes_detail_author_output_tl
                \l__xdyynotes_detail_paper_output_tl
                \l__xdyynotes_detail_year_output_tl
                \l__xdyynotes_detail_page_output_tl
              }
          }
          {
            % 如果book值不是空的，就设置title为book系列
            \tl_set:Nn \l__xdyynotes_detail_title_output_tl
              {
                \l__xdyynotes_detail_author_output_tl
                \l__xdyynotes_detail_book_output_tl
                \l__xdyynotes_detail_year_output_tl
                \l__xdyynotes_detail_page_output_tl
              }
          }
      }
      {
        \tl_set:Nn \l__xdyynotes_detail_title_output_tl
          {
            \group_begin:
              \itshape
              \l__xdyynotes_detail_title_input_tl
            \group_end:
          }
      }
  }
\cs_new:Nn \__xdyynotes_detail_year_output_set:
  {
    \tl_if_blank:VF \l__xdyynotes_detail_year_input_tl
      {
        \tl_set:Nn \l__xdyynotes_detail_year_output_tl
          {
            , ~
            \group_begin:
              \normalfont \l__xdyynotes_detail_year_input_tl.
            \group_end:
          }
      }
  }
% 补充细节
\cs_new:Npn \__xdyynotes_detail_add_output_set:n #1
  {
    \textbf{ 【细节补充】 }
    #1
  }
\tcbset
  {
    detail / .style =
      { 
        enhanced,
        breakable,
        parbox = false,   % 增加的话，内层的tcolorbox会和上方粘连
        left = 2mm,
        right = 3mm,
        middle = 3mm,
        bottom = 1mm,
        segmentation~style = 
          { dash~dot, black, line~width = 0.3pt }, 
        colback = white,
        colframe = teal,
      }
  }

\NewDocumentEnvironment { detail } { +O{} +b }
  {
    \group_begin:
      \keys_set:nn { xdyy-notes / detail } {#1}
      % 处理author
      \__xdyynotes_detail_author_output_set:
      % 处理year
      \__xdyynotes_detail_year_output_set:
      % 处理page
      \__xdyynotes_detail_page_output_set:
      % 处理original
      \__xdyynotes_detail_original_output_set:
      % 处理edition
      \__xdyynotes_detail_edition_output_set:
      % 处理标题
      \__xdyynotes_detail_title_output_set:
      % 输出
      \begin{tcolorbox}
        [
          detail,
          title = { \l__xdyynotes_detail_title_output_tl }
        ]
        \l__xdyynotes_detail_original_output_tl
        \tcblower
        \__xdyynotes_detail_add_output_set:n {#2}
      \end{tcolorbox}
    \group_end:
  }
  {}



% 习题环境 exercise

\skip_new:N \l__xdyynotes_exercise_top_sep_skip
\skip_new:N \l__xdyynotes_exercise_bottom_sep_skip
\int_new:N \g__xdyynotes_exercise_index_int

\keys_define:nn { xdyy-notes / exercise }
  {
    top-sep .skip_set:N = \l__xdyynotes_exercise_top_sep_skip,
    top-sep .initial:n = .5em plus .5em minus .2em,
    bottom-sep .skip_set:N = \l__xdyynotes_exercise_bottom_sep_skip,
    bottom-sep .initial:n = .5em plus .5em minus .2em,
    index .int_gset:N = \g__xdyynotes_exercise_index_int,
  }


\NewDocumentEnvironment { exercise } { +O { } +b }
  { \__xdyynotes_exercise_begin:nn {#1}{#2} }
  { \__xdyynotes_exercise_end:nn {#1}{#2} }

\cs_new:Npn \__xdyynotes_exercise_begin:nn #1#2
  {
    \par
    \int_gincr:N \g__xdyynotes_exercise_index_int
    \keys_set:nn { xdyy-notes / exercise } { #1 }
    \addvspace { \l__xdyynotes_exercise_top_sep_skip }
    % 严格禁止孤行和寡行
    \int_set:Nn \clubpenalty { 10000 }
    \int_set:Nn \widowpenalty { 10000 }
    % 尽量避免在题目中间换行
    \int_set:Nn \interlinepenalty { 301 }
    \int_incr:N \@enumdepth
    \list { \int_use:N \g__xdyynotes_exercise_index_int . }
      {
        \dim_set:Nn \topsep    { 0pt }
        \dim_set:Nn \partopsep { 0pt }
        \dim_set:Nn \itemsep   { 0pt }
        \dim_set:Nn \parsep    { 0pt }
        \dim_set:Nn \leftmargin { 2em }
        \dim_set:Nn \itemindent { 0pt }
        \dim_set:Nn \labelsep   { .7em  }
        \dim_set:Nn \labelwidth { 1.3em }
        \dim_set_eq:NN \listparindent \itemindent
      }
    \item \relax
  }


\cs_new:Npn \__xdyynotes_exercise_end:nn #1#2
  {
      #2
    \endlist
    \addvspace { \l__xdyynotes_exercise_bottom_sep_skip }
  }

\cs_set_eq:NN \__xdyynotes_pretocmd:nnnn \pretocmd
\cs_new:Npn \__xdyynotes_exercise_index_zero_set:n #1
  {
    \__xdyynotes_pretocmd:nnnn {#1}
      {
        \int_gzero:N \g__xdyynotes_exercise_index_int
      }
      {}{}
  }
% 在新的章节开启时把exercise的index设为0
\clist_map_function:nN
  {
    \chaper, \section, \subsection
  }
  \__xdyynotes_exercise_index_zero_set:n


% 勘误环境 correction

% 声明变量
\cs_new:Npn \__xdyynotes_correction_define_input_tl:n #1
  {
    \tl_new:c { l__xdyynotes_correction_ #1 _input_tl }
  }

\cs_new:Npn \__xdyynotes_correction_define_output_tl:n #1
  {
    \tl_new:c { l__xdyynotes_correction_ #1 _output_tl }
  }

\clist_map_function:nN
  {
    book, paper, edition, author, 
    page, original, title, year,
    revision, explanation
  }
  \__xdyynotes_correction_define_input_tl:n

\clist_map_function:nN
  {
    book, paper, edition, author, 
    page, original, title, year,
    revision, explanation
  }
  \__xdyynotes_correction_define_output_tl:n

\keys_define:nn { xdyy-notes / correction }
  {
    book .tl_set:N = \l__xdyynotes_correction_book_input_tl,
    paper .tl_set:N = \l__xdyynotes_correction_paper_input_tl,
    edition .tl_set:N = \l__xdyynotes_correction_edition_input_tl,
    author .tl_set:N = \l__xdyynotes_correction_author_input_tl,
    page .tl_set:N = \l__xdyynotes_correction_page_input_tl,
    original .tl_set:N = \l__xdyynotes_correction_original_input_tl,
    title .tl_set:N = \l__xdyynotes_correction_title_input_tl,
    year .tl_set:N = \l__xdyynotes_correction_year_input_tl,
    revision .tl_set:N = \l__xdyynotes_correction_revision_input_tl,
    explanation .tl_set:N = \l__xdyynotes_correction_explanation_input_tl,
  }


\cs_new:Nn \__xdyynotes_correction_original_output_set:
  {
    \tl_set:Nn \l__xdyynotes_correction_original_output_tl
      {
        \textbf { 【勘误前】 }
        \l__xdyynotes_correction_original_input_tl
      }
  }
\cs_new:Nn \__xdyynotes_correction_revision_output_set:
  {
    \tl_set:Nn \l__xdyynotes_correction_revision_output_tl
      {
        \textbf { 【勘误后】 }
        \l__xdyynotes_correction_revision_input_tl
      }
  }
\cs_new:Nn \__xdyynotes_correction_author_output_set:
  {
    \tl_if_blank:VF \l__xdyynotes_correction_author_input_tl
      {
        \tl_set:Nn \l__xdyynotes_correction_author_output_tl
          {
            \group_begin:
              \itshape \l__xdyynotes_correction_author_input_tl
            \group_end:
            .~
          }
      }
  }
\cs_new:Nn \__xdyynotes_correction_page_output_set:
  {
    \tl_if_blank:VF \l__xdyynotes_correction_page_input_tl
      {
        \tl_set:Nn \l__xdyynotes_correction_page_output_tl
          {
            \quad
            Page:~ \l__xdyynotes_correction_page_input_tl
          }
      }
  }
\cs_new:Nn \__xdyynotes_correction_edition_output_set:
  {
    \tl_if_blank:VF \l__xdyynotes_correction_edition_input_tl
      {
        \tl_set:Nn \l__xdyynotes_correction_edition_output_tl
          {
            , ~
            % \group_begin:
              \l__xdyynotes_correction_edition_input_tl
            % \group_end:
          }
      }
  }
\cs_new:Nn \__xdyynotes_correction_book_output_set:
  {
    \tl_set:Nn \l__xdyynotes_correction_book_output_tl
      {
        \group_begin:
          \itshape 
          \l__xdyynotes_correction_book_input_tl
          \l__xdyynotes_correction_edition_output_tl
        \group_end:
      }
  }
\cs_new:Nn \__xdyynotes_correction_paper_output_set:
  {
    \tl_set:Nn \l__xdyynotes_correction_paper_output_tl
      {
        \group_begin:
          \normalfont
          \l__xdyynotes_correction_paper_input_tl
          \l__xdyynotes_correction_edition_output_tl
        \group_end:
      }
  }
\cs_new:Nn \__xdyynotes_correction_title_output_set:
  {
    \__xdyynotes_correction_book_output_set:
    \__xdyynotes_correction_paper_output_set:
    \tl_if_blank:VTF \l__xdyynotes_correction_title_input_tl
      {
        \tl_if_blank:VTF \l__xdyynotes_correction_book_input_tl
          {
            % 如果book值是空的，就设置title为paper系列
            \tl_set:Nn \l__xdyynotes_correction_title_output_tl
              {
                \l__xdyynotes_correction_author_output_tl
                \l__xdyynotes_correction_paper_output_tl
                \l__xdyynotes_correction_year_output_tl
                \l__xdyynotes_correction_page_output_tl
              }
          }
          {
            % 如果book值不是空的，就设置title为book系列
            \tl_set:Nn \l__xdyynotes_correction_title_output_tl
              {
                \l__xdyynotes_correction_author_output_tl
                \l__xdyynotes_correction_book_output_tl
                \l__xdyynotes_correction_year_output_tl
                \l__xdyynotes_correction_page_output_tl
              }
          }
      }
      {
        \tl_set:Nn \l__xdyynotes_correction_title_output_tl
          {
            \group_begin:
              \itshape
              \l__xdyynotes_correction_title_input_tl
            \group_end:
          }
      }
  }
\cs_new:Nn \__xdyynotes_correction_year_output_set:
  {
    \tl_if_blank:VF \l__xdyynotes_correction_year_input_tl
      {
        \tl_set:Nn \l__xdyynotes_correction_year_output_tl
          {
            , ~
            \group_begin:
              \normalfont \l__xdyynotes_correction_year_input_tl.
            \group_end:
          }
      }
  }
% 勘误解释
\cs_new:Nn \__xdyynotes_correction_explanation_output_set:
  {
    \tl_if_blank:VF \l__xdyynotes_correction_explanation_input_tl
      {
        \tl_set:Nn \l__xdyynotes_correction_explanation_output_tl
          {
            \tcblower
            \textbf{ 【补充解释】 }
            \par
            \l__xdyynotes_correction_explanation_input_tl
          }
      }
  }
\tcbset
  {
    correction / .style =
      { 
        enhanced,
        breakable,
        parbox = false,   % 增加的话，内层的tcolorbox会和上方粘连
        left = 2mm,
        right = 3mm,
        middle = 3mm,
        bottom = 1mm,
        segmentation~style = 
          { dash~dot, black, line~width = 0.3pt }, 
        colback = white,
        colframe = PaleVioletRed,
      }
  }

\NewDocumentCommand { \correction } { +O{} }
  {
    \group_begin:
      \keys_set:nn { xdyy-notes / correction } {#1}
      % 处理author
      \__xdyynotes_correction_author_output_set:
      % 处理year
      \__xdyynotes_correction_year_output_set:
      % 处理page
      \__xdyynotes_correction_page_output_set:
      % 处理original
      \__xdyynotes_correction_original_output_set:
      % 处理revision
      \__xdyynotes_correction_revision_output_set:
      % 处理edition
      \__xdyynotes_correction_edition_output_set:
      % 处理标题
      \__xdyynotes_correction_title_output_set:
      % 输出
      \begin{tcolorbox}
        [
          correction,
          title = { \l__xdyynotes_correction_title_output_tl }
        ]
        \l__xdyynotes_correction_original_output_tl
        \par \noindent
        \l__xdyynotes_correction_revision_output_tl
        % 设置explanation部分
        \__xdyynotes_correction_explanation_output_set:
        \l__xdyynotes_correction_explanation_output_tl
      \end{tcolorbox}
    \group_end:
  }


% 定义充分必要性环境
% 必要性
\NewDocumentEnvironment { necessity } { +b }
  {
    \par \noindent
    \framebox
      {
        $
          \xLongrightarrow 
            { \text{ \normalsize 必要性 } }
        $ 
      }
    \par \addvspace{ .5em plus .5em minus .2em }
    \par #1
    \par \addvspace{ .5em plus .5em minus .2em }
  }
  {}

% 充分性
\NewDocumentEnvironment { sufficiency } { +b }
  {
    \par \noindent 
    \framebox
      {
        $
          \xLongleftarrow 
            { \text{ \normalsize 充分性 } }
        $ 
      }
    \par \addvspace{ .5em plus .5em minus .2em }
    \par #1
    \par \addvspace{ .5em plus .5em minus .2em }
  }
  {
    % \addvspace{ .5em plus .5em minus .2em }
  }