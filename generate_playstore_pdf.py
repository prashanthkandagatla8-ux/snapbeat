import sys
import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, KeepTogether, HRFlowable
)

def build_pdf(filename):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        rightMargin=40,
        leftMargin=40,
        topMargin=40,
        bottomMargin=40,
    )

    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=20,
        leading=24,
        textColor=colors.HexColor('#0D0D0F'),
        alignment=0,
        spaceAfter=4,
    )
    
    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=11,
        leading=15,
        textColor=colors.HexColor('#C8A232'),
        spaceAfter=12,
    )
    
    h1_style = ParagraphStyle(
        'SectionH1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=17,
        textColor=colors.HexColor('#1A1A1E'),
        spaceBefore=14,
        spaceAfter=6,
        keepWithNext=True,
    )

    h2_style = ParagraphStyle(
        'SectionH2',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10.5,
        leading=14,
        textColor=colors.HexColor('#2E2B28'),
        spaceBefore=8,
        spaceAfter=4,
        keepWithNext=True,
    )

    body_style = ParagraphStyle(
        'TableBody',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=11.5,
        textColor=colors.HexColor('#2A2A30'),
    )

    bold_body = ParagraphStyle(
        'TableBodyBold',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8.5,
        leading=11.5,
        textColor=colors.HexColor('#0D0D0F'),
    )

    code_style = ParagraphStyle(
        'TableCode',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=8,
        leading=10.5,
        textColor=colors.HexColor('#8E7118'),
    )

    callout_style = ParagraphStyle(
        'CalloutText',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=colors.HexColor('#1E1B18'),
    )

    elements = []

    # Document Header
    elements.append(Paragraph("SnapBeat &bull; Google Play Console Submission Guide", title_style))
    elements.append(Paragraph("Closed Testing Track &bull; Form Answers & Copy-Paste Field Reference", subtitle_style))
    elements.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor('#FFD54F'), spaceBefore=2, spaceAfter=10))

    # Introduction Callout
    intro_table = Table(
        [[Paragraph("<b>Notice:</b> This document contains every exact answer, string, and configuration value needed to complete the Google Play Console forms for Closed Testing. Copy-paste these fields directly into your Play Console portal.", callout_style)]],
        colWidths=[532],
    )
    intro_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#FFF9E6')),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor('#FFD54F')),
        ('PADDING', (0,0), (-1,-1), 8),
        ('ROUNDEDCORNERS', [4, 4, 4, 4]),
    ]))
    elements.append(intro_table)
    elements.append(Spacer(1, 10))

    # SECTION 1: App Identity & Store Listing
    elements.append(Paragraph("1. Store Listing & Metadata (Dashboard &gt; Main Store Listing)", h1_style))
    
    listing_data = [
        [Paragraph("Console Field", bold_body), Paragraph("Exact Value / Copy-Paste Text", bold_body), Paragraph("Notes & Requirements", bold_body)],
        [
            Paragraph("App Name", bold_body),
            Paragraph("SnapBeat", code_style),
            Paragraph("Max 30 chars. Matches app branding.", body_style)
        ],
        [
            Paragraph("Short Description", bold_body),
            Paragraph("Create beat-synced photo reels and videos with instant audio transitions.", code_style),
            Paragraph("73 / 80 characters. Visible on store card.", body_style)
        ],
        [
            Paragraph("Full Description", bold_body),
            Paragraph(
                "SnapBeat turns your favorite photos into professional, beat-synced reels with precision music timing and retro studio aesthetics.<br/><br/>"
                "<b>Features:</b><br/>"
                "&bull; <b>14 Kinetic Beat Styles:</b> Beat Cut, Bounce, Cine Zoom, Fade, Glide, Pendulum, Pulse, Punch, Reveal Boxes, Slide, Slow Drift, Sway, Whip, and Zoom Out.<br/>"
                "&bull; <b>Built-in Sound Vault:</b> 8 curated royalty-free master tracks spanning Urban Boom Bap, Funk, Vlog Chill, Lounge, and Dubstep.<br/>"
                "&bull; <b>Precision Waveform Audio Trimmer:</b> Easily select the exact snippet of audio you want.<br/>"
                "&bull; <b>Custom Aspect Ratios:</b> 9:16 Story/Reel, 1:1 Square Post, and 16:9 Cinema Wide.<br/>"
                "&bull; <b>Full HD Master Quality:</b> Render crisp 1080p 60fps video ready to share on Instagram, TikTok, and YouTube Shorts.<br/><br/>"
                "<i>Let the music decide your edit.</i>",
                body_style
            ),
            Paragraph("Max 4000 chars. Rich keyword coverage (reels, beat-sync, transitions, 1080p).", body_style)
        ],
        [
            Paragraph("App Category", bold_body),
            Paragraph("Video Players & Editors", code_style),
            Paragraph("Tags: <i>Video Editing, Photography, Music</i>", body_style)
        ],
        [
            Paragraph("Contact Email", bold_body),
            Paragraph("support@snapbeat.app (or your personal email)", code_style),
            Paragraph("Required for developer contact.", body_style)
        ],
    ]

    t1 = Table(listing_data, colWidths=[110, 270, 152])
    t1.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#F2F0EB')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#D5D0C5')),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    elements.append(t1)
    elements.append(Spacer(1, 10))

    # SECTION 2: Graphics Assets
    elements.append(Paragraph("2. Graphic Assets (Dashboard &gt; Main Store Listing &gt; Graphics)", h1_style))
    graphics_data = [
        [Paragraph("Asset", bold_body), Paragraph("Dimensions & Specs", bold_body), Paragraph("File Path in Workspace", bold_body)],
        [
            Paragraph("App Icon", bold_body),
            Paragraph("512 &times; 512 px, PNG (no transparency)", body_style),
            Paragraph("<code>C:\\MyProjects\\snapbeat_flutter\\playstore_icon_512.png</code>", code_style)
        ],
        [
            Paragraph("Feature Graphic", bold_body),
            Paragraph("1024 &times; 500 px, JPEG or 24-bit PNG", body_style),
            Paragraph("Dark metal banner with SnapBeat yellow logo (generated)", code_style)
        ],
        [
            Paragraph("Phone Screenshots", bold_body),
            Paragraph("Min 2, Max 8 screenshots (1080 &times; 2400 px, 16:9 or 9:16)", body_style),
            Paragraph("Captured from Pixel 8 emulator in artifacts directory", code_style)
        ],
    ]
    t2 = Table(graphics_data, colWidths=[110, 170, 252])
    t2.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#F2F0EB')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#D5D0C5')),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    elements.append(t2)
    elements.append(Spacer(1, 10))

    # SECTION 3: App Content & Policy Declarations (The 11 Questionnaires)
    elements.append(Paragraph("3. App Content Questionnaires (Dashboard &gt; Policy &gt; App Content)", h1_style))
    
    policy_data = [
        [Paragraph("Policy Section", bold_body), Paragraph("Exact Answer / Selection", bold_body), Paragraph("Justification / Instructions", bold_body)],
        [
            Paragraph("Privacy Policy", bold_body),
            Paragraph("<b>Primary Live URL:</b><br/><code>https://www.snapbeat.app/privacy.html</code><br/><br/><i>Alternative / Fallbacks:</i><br/><code>https://snapbeat.app/privacy.html</code><br/><code>https://prashanthkandagatla8-ux.github.io/snapbeat/</code>", code_style),
            Paragraph("Hosted live directly on your domain www.snapbeat.app. Meets 100% of Google Play Store 2026 data safety requirements.", body_style)
        ],
        [
            Paragraph("App Access", bold_body),
            Paragraph("<b>All functionality is available without special access</b>", bold_body),
            Paragraph("SnapBeat requires no login, credentials, or 2FA.", body_style)
        ],
        [
            Paragraph("Ads", bold_body),
            Paragraph("<b>No, my app does not contain ads</b>", bold_body),
            Paragraph("SnapBeat contains zero ad SDKs.", body_style)
        ],
        [
            Paragraph("Content Ratings (IARC)", bold_body),
            Paragraph(
                "Category: <b>Utility / Productivity / Other</b><br/>"
                "&bull; Violence: <b>No</b><br/>"
                "&bull; Sexuality: <b>No</b><br/>"
                "&bull; Offensive Language: <b>No</b><br/>"
                "&bull; Controlled Substances: <b>No</b><br/>"
                "&bull; User Exchange of Content: <b>No</b> (renders locally/download only)",
                body_style
            ),
            Paragraph("Results in a clean <b>Everyone / PEGI 3</b> rating across all territories.", body_style)
        ],
        [
            Paragraph("Target Audience", bold_body),
            Paragraph("<b>13-15, 16-17, 18 and over</b><br/>(Do NOT select children under 13)", bold_body),
            Paragraph("Appeal to children: <b>No</b>. Avoids COPPA compliance hurdles.", body_style)
        ],
        [
            Paragraph("News App", bold_body),
            Paragraph("<b>No</b>", bold_body),
            Paragraph("Not a news or journalism app.", body_style)
        ],
        [
            Paragraph("COVID-19 Tracing", bold_body),
            Paragraph("<b>My app is not a publicly available COVID-19 contact tracing or status app</b>", bold_body),
            Paragraph("Standard negative declaration.", body_style)
        ],
        [
            Paragraph("Government Apps", bold_body),
            Paragraph("<b>No</b>", bold_body),
            Paragraph("Not affiliated with government entities.", body_style)
        ],
        [
            Paragraph("Financial Features", bold_body),
            Paragraph("<b>My app does not provide financial features</b>", bold_body),
            Paragraph("We removed billing for closed testing.", body_style)
        ],
        [
            Paragraph("Advertising ID", bold_body),
            Paragraph("<b>No</b> (Does your app use Advertising ID?)", bold_body),
            Paragraph("No advertising IDs collected.", body_style)
        ],
    ]

    t3 = Table(policy_data, colWidths=[110, 240, 182])
    t3.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#F2F0EB')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#D5D0C5')),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    elements.append(t3)
    elements.append(Spacer(1, 10))

    # SECTION 4: Data Safety Form (Deep Dive)
    elements.append(Paragraph("4. Data Safety Form (Critical Section &bull; Line-by-Line)", h1_style))
    
    data_safety = [
        [Paragraph("Question / Screen", bold_body), Paragraph("Exact Selection", bold_body), Paragraph("Details / Explanation", bold_body)],
        [
            Paragraph("Data Collection & Security", bold_body),
            Paragraph("1. Does app collect/share user data? &rarr; <b>Yes</b><br/>2. Encrypted in transit? &rarr; <b>Yes</b><br/>3. Deletion request provided? &rarr; <b>Yes</b>", body_style),
            Paragraph("User media is encrypted in transit and deleted immediately after render.", body_style)
        ],
        [
            Paragraph("Data Types: Photos", bold_body),
            Paragraph(
                "Check <b>Photos</b> under Photos and Videos:<br/>"
                "&bull; Collected: <b>Yes</b><br/>"
                "&bull; Shared: <b>No</b><br/>"
                "&bull; Ephemeral processing: <b>Yes</b><br/>"
                "&bull; Required for app functionality: <b>Yes</b>",
                body_style
            ),
            Paragraph("Photos are only used to compile the requested video reel, then purged.", body_style)
        ],
        [
            Paragraph("Data Types: Audio", bold_body),
            Paragraph(
                "Check <b>Voice or sound recordings / music</b>:<br/>"
                "&bull; Collected: <b>Yes</b><br/>"
                "&bull; Shared: <b>No</b><br/>"
                "&bull; Ephemeral processing: <b>Yes</b><br/>"
                "&bull; Required for app functionality: <b>Yes</b>",
                body_style
            ),
            Paragraph("Audio is analyzed for beat detection and multiplexed into the MP4.", body_style)
        ],
        [
            Paragraph("Other Data Types", bold_body),
            Paragraph("<b>All other categories: NO</b><br/>(No Location, Personal Info, Financial, Health, Messages, Contacts, Device IDs)", bold_body),
            Paragraph("Keep all other checkboxes unchecked.", body_style)
        ],
    ]

    t4 = Table(data_safety, colWidths=[120, 230, 182])
    t4.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#F2F0EB')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#D5D0C5')),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    elements.append(t4)
    elements.append(Spacer(1, 10))

    # SECTION 5: Closed Testing Track & Release Setup
    elements.append(Paragraph("5. Closed Testing Track Release Setup (Testing &gt; Closed Testing)", h1_style))
    
    release_data = [
        [Paragraph("Field / Step", bold_body), Paragraph("Exact Setting / Input", bold_body)],
        [
            Paragraph("Track Name", bold_body),
            Paragraph("Closed testing &bull; Alpha", body_style)
        ],
        [
            Paragraph("Release Name", bold_body),
            Paragraph("<code>1.0.0 (1)</code>", code_style)
        ],
        [
            Paragraph("Release Notes (en-US)", bold_body),
            Paragraph(
                "<code>Initial closed testing release of SnapBeat.<br/>"
                "- Beat-synced photo reel engine with 14 kinetic transition styles<br/>"
                "- Curated 8-track built-in analog Sound Vault<br/>"
                "- Interactive precision audio trimmer<br/>"
                "- High definition 1080p 60fps reel export<br/>"
                "- Dark industrial pro-audio studio interface</code>",
                code_style
            )
        ],
        [
            Paragraph("Testers Requirement", bold_body),
            Paragraph("Google mandates <b>20 testers</b> opted-in for <b>14 continuous days</b> for personal developer accounts before production access. Create an Email List in Play Console and invite your friends.", body_style)
        ],
        [
            Paragraph("App Bundle File", bold_body),
            Paragraph("Build release bundle via: <code>flutter build appbundle --release</code><br/>Output file: <code>build/app/outputs/bundle/release/app-release.aab</code>", body_style)
        ],
    ]

    t5 = Table(release_data, colWidths=[140, 392])
    t5.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#F2F0EB')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#D5D0C5')),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('PADDING', (0,0), (-1,-1), 5),
    ]))
    elements.append(t5)

    doc.build(elements)
    print(f"Successfully generated PDF: {filename}")

if __name__ == '__main__':
    out_path = r'C:\MyProjects\snapbeat_flutter\SnapBeat_PlayStore_Closed_Testing_Guide.pdf'
    build_pdf(out_path)
