<nav class="pcoded-navbar">
    <div class="pcoded-inner-navbar main-menu">
        <!-- begin:: profil sidebar -->
        <div class="">
            <div class="main-menu-header">
                <img class="img-menu-user img-radius" src="<?= (get_users_detail($this->session->userdata('id'))->foto !== null ? upload_url('gambar') . '' . get_users_detail($this->session->userdata('id'))->foto : "//placehold.co/150") ?>" alt="User-Profile-Image">
                <div class="user-details">
                    <p id="more-details"><?= get_users_detail($this->session->userdata('id'))->nama ?></p>
                </div>
            </div>
        </div>
        <!-- end:: profil sidebar -->
        <!-- begin:: menu sidebar -->
        <ul class="pcoded-item pcoded-left-item">
            <li class="<?= ($this->uri->segment(2) === null ? 'active' : '') ?>">
                <a href="<?= admin_url() ?>">
                    <span class="pcoded-micon">
                        <i class="fa fa-circle"></i>
                    </span>
                    <span class="pcoded-mtext">Dashboard</span>
                </a>
            </li>
        </ul>
        <div class="pcoded-navigation-label">Master</div>
        <ul class="pcoded-item pcoded-left-item">
            <li class="<?= ($this->uri->segment(2) === 'klasifikasi' ? 'active' : '') ?>">
                <a href="<?= admin_url() ?>klasifikasi">
                    <span class="pcoded-micon">
                        <i class="fa fa-circle"></i>
                    </span>
                    <span class="pcoded-mtext">Klasifikasi</span>
                </a>
            </li>
        </ul>
        <div class="pcoded-navigation-label">Pustaka</div>
        <ul class="pcoded-item pcoded-left-item">
            <li class="<?= ($this->uri->segment(2) === 'basis' ? 'active' : '') ?>">
                <a href="<?= admin_url() ?>basis">
                    <span class="pcoded-micon">
                        <i class="fa fa-circle"></i>
                    </span>
                    <span class="pcoded-mtext">Basis Pengetahuan</span>
                </a>
            </li>
        </ul>
        <div class="pcoded-navigation-label">Metode</div>
        <ul class="pcoded-item pcoded-left-item">
            <li class="<?= ($this->uri->segment(2) === 'konsultasi' ? 'active' : '') ?>">
                <a href="<?= admin_url() ?>konsultasi">
                    <span class="pcoded-micon">
                        <i class="fa fa-circle"></i>
                    </span>
                    <span class="pcoded-mtext">Konsultasi</span>
                </a>
            </li>
        </ul>
        <div class="pcoded-navigation-label">Laporan</div>
        <ul class="pcoded-item pcoded-left-item">
            <li class="<?= ($this->uri->segment(3) === 'konsultasi' ? 'active' : '') ?>">
                <a href="<?= admin_url() ?>laporan/konsultasi">
                    <span class="pcoded-micon">
                        <i class="fa fa-circle"></i>
                    </span>
                    <span class="pcoded-mtext">Laporan Konsultasi</span>
                </a>
            </li>
        </ul>
        <!-- end:: menu sidebar -->
    </div>
</nav>