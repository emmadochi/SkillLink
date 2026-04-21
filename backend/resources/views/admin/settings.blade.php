@extends('layouts.admin')

@section('title', 'Platform Settings')

@section('header')
    <h1>Settings</h1>
@endsection

@section('content')
    <style>
        .settings-container {
            max-width: 800px;
        }

        .settings-section {
            background: white;
            border-radius: 24px;
            padding: 32px;
            margin-bottom: 32px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        }

        .section-header {
            margin-bottom: 24px;
            padding-bottom: 16px;
            border-bottom: 1px solid #f0f0f0;
        }

        .form-row {
            display: grid;
            grid-template-columns: 200px 1fr;
            gap: 24px;
            margin-bottom: 20px;
            align-items: center;
        }

        label {
            font-size: 14px;
            font-weight: 600;
            color: var(--primary);
        }

        input {
            width: 100%;
            padding: 12px 16px;
            border-radius: 10px;
            border: 1px solid #ddd;
            font-family: inherit;
        }

        .save-btn {
            padding: 14px 32px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
        }
    </style>

    <div class="settings-container">
        <form>
            <div class="settings-section">
                <div class="section-header">
                    <h2 style="margin: 0; font-size: 18px;">Gateway Configurations</h2>
                </div>
                
                <div class="form-row">
                    <label>Paystack Public Key</label>
                    <input type="text" placeholder="pk_test_..." value="pk_test_********************">
                </div>

                <div class="form-row">
                    <label>Paystack Secret Key</label>
                    <input type="password" value="sk_test_********************">
                </div>
            </div>

            <div class="settings-section">
                <div class="section-header">
                    <h2 style="margin: 0; font-size: 18px;">Platform Fees</h2>
                </div>
                
                <div class="form-row">
                    <label>Commission Rate (%)</label>
                    <input type="number" value="10">
                </div>
            </div>

            <button type="button" class="save-btn">Save Changes</button>
        </form>
    </div>
@endsection
